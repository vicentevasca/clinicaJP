import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, X-Api-Secret',
}

// POST /functions/v1/create-consultation-request
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

    const body = await req.json()
    const { client_id, animal_id, service_type, description, priority } = body

    if (!client_id || !animal_id || !service_type || !description) {
      return new Response(JSON.stringify({ error: 'Campos requeridos: client_id, animal_id, service_type, description' }), { status: 400, headers: corsHeaders })
    }

    // Verify client and animal exist and are linked
    const { data: animal } = await supabase
      .from('animals')
      .select('*, client:clients(id, name)')
      .eq('id', animal_id)
      .eq('client_id', client_id)
      .maybeSingle()

    if (!animal) {
      return new Response(JSON.stringify({ error: 'Animal no encontrado o no pertenece al cliente' }), { status: 404, headers: corsHeaders })
    }

    // Get technician user (may be null if none found — don't throw)
    const { data: technician } = await supabase
      .from('users')
      .select('id, telegram_id, name')
      .in('role', ['admin', 'tecnico'])
      .eq('active', true)
      .limit(1)
      .maybeSingle()

    // Create the lead
    const { data: lead, error: leadError } = await supabase.from('leads').insert({
      client_id,
      animal_id,
      assigned_to: technician?.id || null,
      status: 'waiting',
      service_type,
      description,
      priority: priority || 'normal',
      source: 'mi_mascota_portal',
      preferred_date: body.preferred_date || null,
      preferred_time_slot: body.preferred_time_slot || null,
    }).select('*').single()

    if (leadError) throw leadError

    // Log audit
    await supabase.from('audit_log').insert({
      entity: 'lead',
      entity_id: lead.id,
      action: 'create',
      payload: { source: 'mi_mascota_portal', service_type },
    })

    // Lead status history entry
    await supabase.from('lead_status_history').insert({
      lead_id: lead.id,
      from_status: null,
      to_status: 'waiting',
      changed_by: technician?.id || null,
      note: 'Creado desde portal Mi Mascota',
    })

    // Send Telegram notification (never fails — errors are warnings only)
    try {
      if (technician?.telegram_id) {
        const botToken = Deno.env.get('TELEGRAM_BOT_TOKEN')
        if (botToken) {
          const text = [
            `🐾 *Nueva solicitud — Mi Mascota*`,
            ``,
            `👤 *Cliente:* ${animal.client?.name ?? 'N/A'}`,
            `🐶 *Animal:* ${animal.name} (${animal.species})`,
            `🩺 *Servicio:* ${service_type}`,
            `📝 *Descripción:* ${description}`,
            `⏰ *Recibido:* ${new Date().toLocaleString('es-CL', { timeZone: 'America/Santiago' })}`,
          ].join('\n')

          const replyMarkup = {
            inline_keyboard: [
              [
                { text: '📋 Ver detalle', callback_data: `lead_info:${lead.id}` },
                { text: '💬 WhatsApp', callback_data: `lead_whatsapp:${lead.id}` },
              ],
              [
                { text: '🔄 En curso', callback_data: `lead_status_progress:${lead.id}` },
                { text: '🌐 Abrir panel', callback_data: `lead_open_panel:${lead.id}` },
              ],
            ],
          }

          await fetch(`https://api.telegram.org/bot${botToken}/sendMessage`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ chat_id: technician.telegram_id, text, parse_mode: 'Markdown', reply_markup: replyMarkup }),
          })
        }
      }
    } catch (telegramError) {
      console.error('Telegram notification failed:', telegramError)
    }

    return new Response(
      JSON.stringify({ success: true, lead_id: lead.id, message: 'Solicitud creada exitosamente' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('create-consultation-request error:', error)
    return new Response(JSON.stringify({ error: 'Error interno: ' + error.message }), { status: 500, headers: corsHeaders })
  }
})
