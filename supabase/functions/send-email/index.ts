import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, X-Api-Secret',
}

type EmailTemplate = 'lead_confirmation' | 'lead_new_internal' | 'visit_reminder' | 'stock_alert'

const TEMPLATES: Record<EmailTemplate, (vars: Record<string, string>) => { subject: string; html: string }> = {
  lead_confirmation: (v) => ({
    subject: `Recibimos tu solicitud 🐾 — ${v.animal_name}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #0f172a; color: #f1f5f9; padding: 32px; border-radius: 12px;">
        <h1 style="color: #22c55e; margin-bottom: 24px;">🐾 Solicitud recibida</h1>
        <p style="font-size: 16px; line-height: 1.6;">Hola <strong>${v.client_name}</strong>,</p>
        <p style="font-size: 16px; line-height: 1.6;">Recibimos tu solicitud para <strong>${v.animal_name}</strong>. Nos comunicaremos contigo a la brevedad.</p>
        <div style="background: #1e293b; border-radius: 8px; padding: 16px; margin: 24px 0;">
          <p style="margin: 0; color: #94a3b8; font-size: 14px;">📋 Servicio solicitado</p>
          <p style="margin: 4px 0 0; font-size: 18px; color: #22c55e;">${v.service_type}</p>
        </div>
        <p style="font-size: 14px; color: #64748b;">Equipo VetDesk — Clínica JP</p>
      </div>`,
  }),

  lead_new_internal: (v) => ({
    subject: `🔔 Nuevo lead: ${v.client_name} — ${v.animal_name}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #0f172a; color: #f1f5f9; padding: 32px; border-radius: 12px;">
        <h1 style="color: #22c55e;">🐾 Nuevo lead recibido</h1>
        <table style="width: 100%; border-collapse: collapse; margin: 24px 0;">
          <tr><td style="padding: 8px 0; color: #94a3b8;">Cliente</td><td style="padding: 8px 0;"><strong>${v.client_name}</strong></td></tr>
          <tr><td style="padding: 8px 0; color: #94a3b8;">Teléfono</td><td style="padding: 8px 0;">${v.client_phone}</td></tr>
          <tr><td style="padding: 8px 0; color: #94a3b8;">Animal</td><td style="padding: 8px 0;"><strong>${v.animal_name}</strong></td></tr>
          <tr><td style="padding: 8px 0; color: #94a3b8;">Servicio</td><td style="padding: 8px 0;">${v.service_type}</td></tr>
        </table>
        <p style="color: #64748b; font-size: 14px;">Revisa el panel de VetDesk para más detalles.</p>
      </div>`,
  }),

  visit_reminder: (v) => ({
    subject: `📅 Recordatorio de visita — ${v.animal_name}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #0f172a; color: #f1f5f9; padding: 32px; border-radius: 12px;">
        <h1 style="color: #22c55e;">📅 Recordatorio de visita</h1>
        <p style="font-size: 16px; line-height: 1.6;">Hola <strong>${v.client_name}</strong>,</p>
        <p style="font-size: 16px; line-height: 1.6;">Te recordamos que tienes una visita programada para <strong>${v.animal_name}</strong>:</p>
        <div style="background: #1e293b; border-radius: 8px; padding: 16px; margin: 24px 0;">
          <p style="margin: 0; font-size: 18px;"><strong>📅 ${v.date}</strong> — <strong>🕐 ${v.time}</strong></p>
          <p style="margin: 8px 0 0; color: #94a3b8;">📍 ${v.address}</p>
        </div>
        <p style="font-size: 14px; color: #64748b;">Equipo VetDesk — Clínica JP</p>
      </div>`,
  }),

  stock_alert: (v) => ({
    subject: `⚠️ Alerta de stock — ${v.item_name}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #0f172a; color: #f1f5f9; padding: 32px; border-radius: 12px;">
        <h1 style="color: #ef4444;">⚠️ Alerta de stock crítico</h1>
        <p style="font-size: 16px; line-height: 1.6;">El siguiente insumo está bajo stock mínimo:</p>
        <div style="background: #1e293b; border-radius: 8px; padding: 16px; margin: 24px 0;">
          <p style="margin: 0; font-size: 18px;"><strong>${v.item_name}</strong></p>
          <p style="margin: 8px 0 0; color: #ef4444;">Stock actual: ${v.stock} | Mínimo: ${v.min_stock}</p>
        </div>
        <p style="font-size: 14px; color: #64748b;">Revisa el inventario en VetDesk para reponer.</p>
      </div>`,
  }),
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  // Validar X-Api-Secret
  const apiSecret = Deno.env.get('VETDESK_PORTAL_SECRET')
  const sentSecret = req.headers.get('X-Api-Secret')
  if (apiSecret && sentSecret !== apiSecret) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: corsHeaders })
  }

  const resendApiKey = Deno.env.get('RESEND_API_KEY')
  const fromEmail = Deno.env.get('RESEND_FROM_EMAIL') || 'notificaciones@vetdesk.cl'

  if (!resendApiKey) {
    return new Response(JSON.stringify({ error: 'RESEND_API_KEY not configured' }), { status: 500, headers: corsHeaders })
  }

  try {
    const { to, template, vars = {} } = await req.json()

    if (!to) return new Response(JSON.stringify({ error: 'to email requerido' }), { status: 400, headers: corsHeaders })
    if (!template) return new Response(JSON.stringify({ error: 'template requerido' }), { status: 400, headers: corsHeaders })

    const templateFn = TEMPLATES[template as EmailTemplate]
    if (!templateFn) return new Response(JSON.stringify({ error: 'Template no válido' }), { status: 400, headers: corsHeaders })

    const { subject, html } = templateFn(vars)

    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${resendApiKey}`,
      },
      body: JSON.stringify({ from: fromEmail, to: [to], subject, html }),
    })

    if (!response.ok) {
      const errorText = await response.text()
      console.error('Resend error:', errorText)
      return new Response(JSON.stringify({ error: 'Failed to send email' }), { status: 500, headers: corsHeaders })
    }

    const result = await response.json()
    return new Response(JSON.stringify({ success: true, id: result.id }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
  } catch (error) {
    console.error('send-email error:', error)
    return new Response(JSON.stringify({ error: 'Error interno' }), { status: 500, headers: corsHeaders })
  }
})
