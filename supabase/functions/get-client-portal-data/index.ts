import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, X-Api-Secret',
}

// GET /functions/v1/get-client-portal-data?rut=... or ?phone=...
serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  const apiSecret = Deno.env.get('VETDESK_PORTAL_SECRET')
  const sentSecret = req.headers.get('X-Api-Secret')
  if (apiSecret && sentSecret !== apiSecret) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const url = new URL(req.url)
    const rut = url.searchParams.get('rut')
    const phone = url.searchParams.get('phone')

    if (!rut && !phone) {
      return new Response(JSON.stringify({ error: 'Se requiere rut o phone' }), { status: 400, headers: corsHeaders })
    }

    // Build client query
    let clientQuery = supabase.from('clients').select('*')
    if (rut) {
      const normalized = rut.replace(/[^0-9kK]/g, '').toLowerCase()
      clientQuery = clientQuery.eq('rut', normalized)
    } else {
      const normalized = phone.replace(/\D/g, '')
      const withPrefix = normalized.startsWith('56') ? '+' + normalized : '+56' + normalized
      clientQuery = clientQuery.eq('phone', withPrefix)
    }

    const { data: client, error: clientError } = await clientQuery.single()
    if (clientError || !client) {
      return new Response(JSON.stringify({ error: 'Cliente no encontrado' }), { status: 404, headers: corsHeaders })
    }

    // Get animals with clinical records
    const { data: animals } = await supabase
      .from('animals')
      .select('*, clinical_records(id, created_at, weight_kg, temperature_c, diagnosis, treatment, prescriptions, observations, next_visit_rec, visit:visits(id, scheduled_at, status, completed_at, address))')
      .eq('client_id', client.id)
      .order('created_at', { ascending: true })

    // Get recent visits and vaccinations for each animal
    const animalsWithVisits = await Promise.all((animals || []).map(async (animal) => {
      const [{ data: visits }, { data: vaccinations }] = await Promise.all([
        supabase
          .from('visits')
          .select('id, scheduled_at, status, address, completed_at, procedures:visit_procedures(executed, procedure:procedures(id, name, category))')
          .eq('animal_id', animal.id)
          .order('scheduled_at', { ascending: false })
          .limit(10),
        supabase
          .from('vaccinations')
          .select('id, vaccine_name, batch_number, lab_name, dose_number, administered_at, next_due_date, notes')
          .eq('animal_id', animal.id)
          .order('administered_at', { ascending: false }),
      ])

      const sortedRecords = (animal.clinical_records || []).sort((a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
      )

      return {
        ...animal,
        clinical_records: sortedRecords,
        recent_visits:    visits        || [],
        vaccinations:     vaccinations  || [],
      }
    }))

    return new Response(
      JSON.stringify({ client, animals: animalsWithVisits }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('get-client-portal-data error:', error)
    return new Response(JSON.stringify({ error: 'Error interno' }), { status: 500, headers: corsHeaders })
  }
})
