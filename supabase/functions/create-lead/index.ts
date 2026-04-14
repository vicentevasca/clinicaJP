import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const body = await req.json()

    // 1. Validar campos requeridos
    const required = ['client_name','client_phone','region','comuna','address','animal_name','animal_species','service_type','description']
    for (const field of required) {
      if (!body[field]) return new Response(JSON.stringify({ error: `Campo requerido: ${field}` }), { status: 400, headers: corsHeaders })
    }

    // 2. Buscar o crear cliente
    let clientId: string
    const { data: existing } = await supabase.from('clients').select('id').eq('phone', body.client_phone).single()
    if (existing) {
      clientId = existing.id
    } else {
      const { data: newClient, error } = await supabase.from('clients').insert({
        name: body.client_name, phone: body.client_phone, email: body.client_email,
        region: body.region, comuna: body.comuna, address: body.address,
      }).select('id').single()
      if (error) throw error
      clientId = newClient.id
    }

    // 3. Crear animal
    const { data: animal, error: animalError } = await supabase.from('animals').insert({
      client_id: clientId, name: body.animal_name, species: body.animal_species,
      breed: body.animal_breed, sex: body.animal_sex,
    }).select('id').single()
    if (animalError) throw animalError

    // 4. Crear lead
    const { data: lead, error: leadError } = await supabase.from('leads').insert({
      client_id: clientId, animal_id: animal.id, status: 'waiting',
      service_type: body.service_type, description: body.description,
      priority: body.priority || 'normal', source: 'web_form',
    }).select('id').single()
    if (leadError) throw leadError

    // 5. Audit log
    await supabase.from('audit_log').insert({
      entity: 'lead', entity_id: lead.id, action: 'create',
      payload: { source: 'web_form', service_type: body.service_type }
    })

    // 6. TODO: Notificación Telegram (implementar con TELEGRAM_BOT_TOKEN)
    // 7. TODO: Email confirmación via send-email

    return new Response(
      JSON.stringify({ success: true, lead_id: lead.id, message: 'Lead creado exitosamente' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('create-lead error:', error)
    return new Response(JSON.stringify({ error: 'Error interno' }), { status: 500, headers: corsHeaders })
  }
})
