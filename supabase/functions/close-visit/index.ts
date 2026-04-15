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

    // Validate Authorization header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: corsHeaders })

    // Verify JWT and get user
    const { data: { user }, error: authError } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''))
    if (authError || !user) return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: corsHeaders })

    const body = await req.json()
    const { visit_id, clinical, procedures_executed = [], inventory_used = [] } = body

    if (!visit_id) return new Response(JSON.stringify({ error: 'visit_id requerido' }), { status: 400, headers: corsHeaders })

    // 1. Verify visit exists and belongs to user
    const { data: visit, error: visitError } = await supabase
      .from('visits').select('*, leads(*)').eq('id', visit_id).single()
    if (visitError || !visit) return new Response(JSON.stringify({ error: 'Visita no encontrada' }), { status: 404, headers: corsHeaders })

    // 2. Create clinical record
    const { data: clinicalRecord, error: clinicalError } = await supabase
      .from('clinical_records').insert({
        visit_id,
        animal_id: visit.animal_id,
        lead_id: visit.lead_id,
        weight_kg: clinical?.weight_kg,
        temperature_c: clinical?.temperature_c,
        diagnosis: clinical?.diagnosis,
        treatment: clinical?.treatment,
        prescriptions: clinical?.prescriptions,
        observations: clinical?.observations,
        next_visit_rec: clinical?.next_visit_rec,
        created_by: user.id,
      }).select('id').single()
    if (clinicalError) throw clinicalError

    // 3. Mark procedures as executed
    if (procedures_executed.length > 0) {
      const { error: procError } = await supabase
        .from('visit_procedures')
        .update({ executed: true })
        .eq('visit_id', visit_id)
        .in('id', procedures_executed)
      if (procError) console.error('visit_procedures update error:', procError)
    }

    // 4. Deduct inventory
    const stockAlerts: Array<{ inventory_id: string; name: string; stock: number; min_stock: number }> = []
    for (const usage of inventory_used) {
      const { inventory_id, quantity_used } = usage

      // Get current stock
      const { data: item } = await supabase
        .from('inventory').select('name, stock, min_stock').eq('id', inventory_id).single()
      if (!item) continue

      const newStock = Number(item.stock) - Number(quantity_used)

      // Update stock
      await supabase.from('inventory').update({ stock: newStock }).eq('id', inventory_id)

      // Record usage
      await supabase.from('inventory_usage').insert({
        visit_id, inventory_id, quantity_used,
      })

      // Check if below min_stock
      if (newStock <= Number(item.min_stock)) {
        stockAlerts.push({ inventory_id, name: item.name, stock: newStock, min_stock: Number(item.min_stock) })
      }
    }

    // 5. Update visit status
    await supabase.from('visits').update({
      status: 'completed',
      completed_at: new Date().toISOString(),
      notes: body.visit_notes,
    }).eq('id', visit_id)

    // 6. Update lead status to done
    await supabase.from('leads').update({ status: 'done' }).eq('id', visit.lead_id)

    // 7. Log status changes
    await supabase.from('lead_status_history').insert({
      lead_id: visit.lead_id, from_status: visit.leads?.status, to_status: 'done', changed_by: user.id,
      note: 'Cerrada desde close-visit',
    })

    // 8. Audit log
    await supabase.from('audit_log').insert({
      user_id: user.id, entity: 'visit', entity_id: visit_id, action: 'close',
      payload: { clinical_record_id: clinicalRecord.id, inventory_used, stock_alerts: stockAlerts },
    })

    return new Response(
      JSON.stringify({ success: true, clinical_record_id: clinicalRecord.id, stock_alerts: stockAlerts }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('close-visit error:', error)
    return new Response(JSON.stringify({ error: 'Error interno: ' + error.message }), { status: 500, headers: corsHeaders })
  }
})
