import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

type Template = 'initial_contact' | 'visit_confirmation' | 'follow_up' | 'custom'

const TEMPLATES: Record<Exclude<Template, 'custom'>, (vars: Record<string, string>) => string> = {
  initial_contact: (v) =>
    `Hola ${v.client_name}! te hablo desde la clínica a domicilio JP, leí tu mensaje por nuestra plataforma web y me gustaría saber más sobre el caso de ${v.animal_name}. ¿Tienes un momento para conversar?`,

  visit_confirmation: (v) =>
    `Hola ${v.client_name}! confirmo tu visita para ${v.animal_name} el ${v.date} a las ${v.time} en ${v.address}. Cualquier consulta, escríbeme aquí. ¡Nos vemos pronto! 🐾`,

  follow_up: (v) =>
    `Hola ${v.client_name}! te escribo para hacer seguimiento al caso de ${v.animal_name}. ¿Cómo ha estado? ¿Pudiste conseguir lo indicado?`,
}

function buildWhatsAppUrl(phone: string, text: string): string {
  const digits = phone.replace(/\D/g, '')
  const encoded = encodeURIComponent(text)
  return `https://wa.me/${digits}?text=${encoded}`
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const authHeader = req.headers.get('Authorization')
    if (!authHeader) return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: corsHeaders })

    const { data: { user } } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''))
    if (!user) return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: corsHeaders })

    const { lead_id, template = 'initial_contact', custom_text } = await req.json()

    if (!lead_id) return new Response(JSON.stringify({ error: 'lead_id requerido' }), { status: 400, headers: corsHeaders })

    const { data: lead } = await supabase
      .from('leads').select('*, clients(*), animals(*)').eq('id', lead_id).single()
    if (!lead) return new Response(JSON.stringify({ error: 'Lead no encontrado' }), { status: 404, headers: corsHeaders })

    const vars = {
      client_name: lead.clients?.name ?? '',
      animal_name: lead.animals?.name ?? '',
      phone: lead.clients?.phone ?? '',
      address: lead.clients?.address ?? '',
      date: '', time: '', // filled from visit if needed
    }

    let text: string
    if (template === 'custom' && custom_text) {
      // Replace placeholders in custom text
      text = custom_text
        .replace(/\{\{client_name\}\}/g, vars.client_name)
        .replace(/\{\{animal_name\}\}/g, vars.animal_name)
    } else {
      text = TEMPLATES[template as Exclude<Template, 'custom'>]?.(vars) ?? TEMPLATES.initial_contact(vars)
    }

    const whatsapp_url = buildWhatsAppUrl(vars.phone, text)

    return new Response(
      JSON.stringify({ text, whatsapp_url, phone: vars.phone }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('whatsapp-preview error:', error)
    return new Response(JSON.stringify({ error: 'Error interno' }), { status: 500, headers: corsHeaders })
  }
})
