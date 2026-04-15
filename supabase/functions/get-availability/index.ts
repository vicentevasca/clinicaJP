import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, X-Api-Secret',
}

// GET /functions/v1/get-availability?days=7
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
    const days = Math.min(parseInt(url.searchParams.get('days') || '7'), 14)

    // Get the admin/tecnico user (first user with role admin or tecnico)
    const { data: technician } = await supabase
      .from('users')
      .select('id')
      .in('role', ['admin', 'tecnico'])
      .eq('active', true)
      .limit(1)
      .single()

    if (!technician) {
      return new Response(JSON.stringify({ error: 'Técnico no encontrado' }), { status: 404, headers: corsHeaders })
    }

    // Get working hours
    const { data: workingHours } = await supabase
      .from('working_hours')
      .select('*')
      .eq('user_id', technician.id)
      .eq('active', true)
      .order('day_of_week')

    // Build working hours map
    const hoursMap: Record<number, { start: string; end: string }> = {}
    for (const wh of (workingHours || [])) {
      hoursMap[wh.day_of_week] = { start: wh.start_time.slice(0, 5), end: wh.end_time.slice(0, 5) }
    }

    // Default working hours (Mon-Fri 8:00-20:00)
    const defaultHours = [
      { day: 1, start: '08:00', end: '20:00' },
      { day: 2, start: '08:00', end: '20:00' },
      { day: 3, start: '08:00', end: '20:00' },
      { day: 4, start: '08:00', end: '20:00' },
      { day: 5, start: '08:00', end: '20:00' },
    ]

    // Generate next N days
    const slots = []
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    for (let d = 0; d < days; d++) {
      const date = new Date(today)
      date.setDate(date.getDate() + d)
      const dayOfWeek = date.getDay()
      const dateStr = date.toISOString().slice(0, 10)

      // Map JS day 0=Domingo to our 0=Domingo
      const wh = hoursMap[dayOfWeek]
      const isWorkingDay = wh != null || defaultHours.some(h => h.day === dayOfWeek)

      // Get existing visits for this technician on this date
      const dayStart = date.toISOString()
      const dayEnd = new Date(date.getTime() + 24 * 60 * 60 * 1000 - 1).toISOString()
      const { data: existingVisits } = await supabase
        .from('visits')
        .select('scheduled_at, duration_min')
        .eq('assigned_to', technician.id)
        .in('status', ['scheduled', 'confirmed', 'in_progress'])
        .gte('scheduled_at', dayStart)
        .lte('scheduled_at', dayEnd)

      // Check if there's a visit in each time slot
      const manianaBusy = existingVisits?.some(v => {
        const h = new Date(v.scheduled_at).getHours()
        return h >= 8 && h < 13
      })
      const tardeBusy = existingVisits?.some(v => {
        const h = new Date(v.scheduled_at).getHours()
        return h >= 13 && h < 19
      })
      const nocheBusy = existingVisits?.some(v => {
        const h = new Date(v.scheduled_at).getHours()
        return h >= 19 && h < 21
      })

      const dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
      slots.push({
        date: dateStr,
        day_name: dayNames[dayOfWeek],
        is_working_day: isWorkingDay,
        time_slots: {
          maniana: { available: isWorkingDay && !manianaBusy },
          tarde: { available: isWorkingDay && !tardeBusy },
          noche: { available: isWorkingDay && !nocheBusy },
        },
      })
    }

    return new Response(
      JSON.stringify({ slots }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('get-availability error:', error)
    return new Response(JSON.stringify({ error: 'Error interno' }), { status: 500, headers: corsHeaders })
  }
})
