import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ─── Telegram Notification ──────────────────────────────────────────────────
async function sendTelegramMessage(botToken: string, chatId: string, text: string, replyMarkup?: object) {
  const body: Record<string, unknown> = { chat_id: chatId, text, parse_mode: 'Markdown' }
  if (replyMarkup) body.reply_markup = replyMarkup
  await fetch(`https://api.telegram.org/bot${botToken}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
}

async function notifyNewLead(botToken: string, adminChatId: string, lead: Record<string, unknown>, animal: Record<string, unknown>, client: Record<string, unknown>) {
  const text = [
    `🐾 *Nuevo lead recibido*`,
    ``,
    `👤 *Cliente:* ${client.name} — ${client.phone}`,
    `🐶 *Paciente:* ${animal.name} (${animal.species})`,
    `🏠 *Ubicación:* ${client.comuna}, ${client.region}`,
    `🩺 *Servicio:* ${lead.service_type}`,
    `📝 *Descripción:* ${lead.description ?? 'Sin descripción'}`,
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

  await sendTelegramMessage(botToken, adminChatId, text, replyMarkup)
}

// ─── Normalize phone to +56 format ──────────────────────────────────────────
function normalizePhone(phone: string): string {
  const digits = phone.replace(/\D/g, '')
  if (digits.startsWith('56') && digits.length === 11) return '+' + digits
  if (digits.startsWith('9') && digits.length === 9) return '+56' + digits
  if (digits.startsWith('9') && digits.length === 10) return '+56' + digits.slice(1)
  return digits.length >= 9 ? '+56' + digits : phone
}

// ─── Main Handler ────────────────────────────────────────────────────────────
serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  const botToken = Deno.env.get('TELEGRAM_BOT_TOKEN')
  const adminChatId = Deno.env.get('TELEGRAM_ADMIN_CHAT_ID')

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

    const phone = normalizePhone(body.client_phone)

    // 2. Buscar o crear cliente
    let clientId: string
    let client: Record<string, unknown>
    const { data: existing } = await supabase.from('clients').select('*').eq('phone', phone).single()
    if (existing) {
      clientId = existing.id
      client = existing
    } else {
      const { data: newClient, error } = await supabase.from('clients').insert({
        name: body.client_name, phone, email: body.client_email,
        region: body.region, comuna: body.comuna, address: body.address,
      }).select('*').single()
      if (error) throw error
      clientId = newClient.id
      client = newClient
    }

    // 3. Crear animal
    const { data: animal, error: animalError } = await supabase.from('animals').insert({
      client_id: clientId, name: body.animal_name, species: body.animal_species,
      breed: body.animal_breed, sex: body.animal_sex,
    }).select('*').single()
    if (animalError) throw animalError

    // 4. Crear lead
    const { data: lead, error: leadError } = await supabase.from('leads').insert({
      client_id: clientId, animal_id: animal.id, status: 'waiting',
      service_type: body.service_type, description: body.description,
      priority: body.priority || 'normal', source: 'web_form',
    }).select('*').single()
    if (leadError) throw leadError

    // 5. Audit log
    await supabase.from('audit_log').insert({
      entity: 'lead', entity_id: lead.id, action: 'create',
      payload: { source: 'web_form', service_type: body.service_type, client_name: body.client_name, animal_name: body.animal_name }
    })

    // 6. Notificación Telegram
    if (botToken && adminChatId) {
      try {
        await notifyNewLead(botToken, adminChatId, lead, animal, client)
      } catch (telegramError) {
        console.error('Telegram notification failed:', telegramError)
        // No fallar el lead por esto
      }
    }

    // 7. Email de confirmación (llama a send-email edge function si tenemos email del cliente)
    // Por ahora solo notifica internamente

    return new Response(
      JSON.stringify({ success: true, lead_id: lead.id, message: 'Lead creado exitosamente' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('create-lead error:', error)
    return new Response(JSON.stringify({ error: 'Error interno' }), { status: 500, headers: corsHeaders })
  }
})
