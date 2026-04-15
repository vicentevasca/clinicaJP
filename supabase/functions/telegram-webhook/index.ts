import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, X-Telegram-Bot-Api-Secret-Token',
}

// ─── Telegram API helpers ────────────────────────────────────────────────────
async function answerCallback(botToken: string, callbackQueryId: string, text?: string) {
  const body: Record<string, unknown> = { callback_query_id: callbackQueryId }
  if (text) { body.text = text; body.show_alert = false }
  await fetch(`https://api.telegram.org/bot${botToken}/answerCallbackQuery`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
}

async function editMessage(botToken: string, chatId: string, messageId: number, text: string, replyMarkup?: object) {
  const body: Record<string, unknown> = {
    chat_id: chatId, message_id: messageId, text, parse_mode: 'Markdown',
  }
  if (replyMarkup) body.reply_markup = replyMarkup
  await fetch(`https://api.telegram.org/bot${botToken}/editMessageText`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
}

async function sendMessage(botToken: string, chatId: string, text: string, replyMarkup?: object) {
  const body: Record<string, unknown> = { chat_id: chatId, text, parse_mode: 'Markdown' }
  if (replyMarkup) body.reply_markup = replyMarkup
  await fetch(`https://api.telegram.org/bot${botToken}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
}

// ─── Build WhatsApp deep link ────────────────────────────────────────────────
function buildWhatsAppUrl(phone: string, text: string): string {
  const cleanPhone = phone.replace(/\D/g, '')
  const encoded = encodeURIComponent(text)
  return `https://wa.me/${cleanPhone}?text=${encoded}`
}

// ─── Status change helper ───────────────────────────────────────────────────
async function changeLeadStatus(supabase: ReturnType<typeof createClient>, leadId: string, newStatus: string, userId?: string) {
  // Get current lead
  const { data: lead, error: leadError } = await supabase
    .from('leads').select('*, clients(*), animals(*)').eq('id', leadId).single()
  if (leadError || !lead) throw new Error('Lead no encontrado')

  const { error: updateError } = await supabase
    .from('leads').update({ status: newStatus, updated_at: new Date().toISOString() }).eq('id', leadId)
  if (updateError) throw updateError

  // Log status change
  await supabase.from('lead_status_history').insert({
    lead_id: leadId, from_status: lead.status, to_status: newStatus, changed_by: userId || null,
  })

  await supabase.from('audit_log').insert({
    entity: 'lead', entity_id: leadId, action: 'status_change',
    payload: { from: lead.status, to: newStatus },
  })

  return lead
}

// ─── Main Handler ────────────────────────────────────────────────────────────
serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  const botToken = Deno.env.get('TELEGRAM_BOT_TOKEN')
  const webhookSecret = Deno.env.get('TELEGRAM_WEBHOOK_SECRET')

  // Validate webhook secret
  const secretToken = req.headers.get('X-Telegram-Bot-Api-Secret-Token')
  if (webhookSecret && secretToken !== webhookSecret) {
    return new Response('Unauthorized', { status: 401 })
  }

  if (!botToken) {
    return new Response(JSON.stringify({ error: 'Bot token not configured' }), { status: 500, headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const update = await req.json()

    // Handle callback_query (inline button press)
    if (update.callback_query) {
      const { id: callbackQueryId, data, message } = update.callback_query
      const telegramUserId = update.callback_query.from.id
      const chatId = String(telegramUserId)
      const messageId = message?.message_id
      const [action, ...rest] = (data || '').split(':')
      const leadId = rest.join(':')

      // Verify the Telegram user is authorized (has telegram_id in users table)
      const { data: authorizedUser } = await supabase
        .from('users').select('id').eq('telegram_id', telegramUserId).single()
      if (!authorizedUser) {
        await answerCallback(botToken, callbackQueryId, '❌ No estás autorizado para usar este bot.')
        return new Response('Unauthorized', { status: 401 })
      }

      const panelUrl = Deno.env.get('VITE_PANEL_URL') || 'https://vetdesk.vercel.app/app'

      if (action === 'lead_info') {
        await answerCallback(botToken, callbackQueryId)
        const { data: lead } = await supabase
          .from('leads').select('*, clients(*), animals(*)').eq('id', leadId).single()
        if (lead) {
          const statusText = lead.status === 'waiting' ? '⏳ En espera' :
                            lead.status === 'in_progress' ? '🔄 En curso' :
                            lead.status === 'done' ? '✅ Cerrado' : '❌ Cancelado'
          const text = [
            `📋 *Detalle del lead*`,
            ``,
            `👤 *Cliente:* ${lead.clients?.name ?? 'N/A'} — ${lead.clients?.phone ?? 'N/A'}`,
            `🐶 *Animal:* ${lead.animals?.name ?? 'N/A'} (${lead.animals?.species ?? 'N/A'})`,
            `🏠 *Dirección:* ${lead.clients?.address ?? 'N/A'}, ${lead.clients?.comuna ?? 'N/A'}`,
            ``,
            `📌 *Estado:* ${statusText}`,
            `🩺 *Servicio:* ${lead.service_type}`,
            `📝 *Descripción:* ${lead.description ?? 'Sin descripción'}`,
            `⏰ *Recibido:* ${new Date(lead.created_at).toLocaleString('es-CL', { timeZone: 'America/Santiago' })}`,
          ].join('\n')
          await sendMessage(botToken, chatId, text)
        }
        return new Response('ok', { headers: corsHeaders })
      }

      if (action === 'lead_whatsapp') {
        const { data: lead } = await supabase
          .from('leads').select('*, clients(*), animals(*)').eq('id', leadId).single()
        if (!lead) {
          await answerCallback(botToken, callbackQueryId, 'Lead no encontrado')
          return new Response('ok', { headers: corsHeaders })
        }
        const text = `Hola ${lead.clients?.name}! te hablo desde la clínica a domicilio JP, leí tu mensaje por nuestra plataforma web y me gustaría saber más sobre el caso de ${lead.animals?.name}. ¿Tienes un momento para conversar?`
        const whatsappUrl = buildWhatsAppUrl(lead.clients?.phone ?? '', text)
        await answerCallback(botToken, callbackQueryId)
        await sendMessage(botToken, chatId, `💬 *WhatsApp*\n\n${text}\n\n🔗 ${whatsappUrl}`)
        return new Response('ok', { headers: corsHeaders })
      }

      if (action === 'lead_status_progress') {
        try {
          const lead = await changeLeadStatus(supabase, leadId, 'in_progress')
          await answerCallback(botToken, callbackQueryId, '🔄 Marcado como en curso')
          const newText = message?.text + '\n\n✅ *Estado actualizado: En curso*'
          if (messageId) {
            const replyMarkup = {
              inline_keyboard: [
                [
                  { text: '📋 Ver detalle', callback_data: `lead_info:${leadId}` },
                  { text: '💬 WhatsApp', callback_data: `lead_whatsapp:${leadId}` },
                ],
                [
                  { text: '✅ Marcar hecho', callback_data: `lead_status_done:${leadId}` },
                  { text: '🌐 Abrir panel', callback_data: `lead_open_panel:${leadId}` },
                ],
              ],
            }
            await editMessage(botToken, chatId, messageId, newText ?? '', replyMarkup)
          }
        } catch (e) {
          await answerCallback(botToken, callbackQueryId, '❌ Error al actualizar')
        }
        return new Response('ok', { headers: corsHeaders })
      }

      if (action === 'lead_status_done') {
        try {
          await changeLeadStatus(supabase, leadId, 'done')
          await answerCallback(botToken, callbackQueryId, '✅ Lead cerrado')
          if (messageId) {
            const newText = (message?.text ?? '') + '\n\n✅ *Estado actualizado: Cerrado*'
            await editMessage(botToken, chatId, messageId, newText)
          }
        } catch (e) {
          await answerCallback(botToken, callbackQueryId, '❌ Error al cerrar')
        }
        return new Response('ok', { headers: corsHeaders })
      }

      if (action === 'lead_open_panel') {
        await answerCallback(botToken, callbackQueryId)
        await sendMessage(botToken, chatId, `🌐 *Abrir panel*\n\n${panelUrl}/leads/${leadId}`)
        return new Response('ok', { headers: corsHeaders })
      }

      await answerCallback(botToken, callbackQueryId)
      return new Response('ok', { headers: corsHeaders })
    }

    // Handle regular message (optional: process incoming messages from admin)
    if (update.message) {
      // Future: handle text commands from admin
    }

    return new Response('ok', { headers: corsHeaders })
  } catch (error) {
    console.error('telegram-webhook error:', error)
    return new Response(JSON.stringify({ error: 'Internal error' }), { status: 500, headers: corsHeaders })
  }
})
