import { supabase } from './supabase.js'

const LEAD_SELECT = `
  id, status, service_type, description, priority, source,
  preferred_date, preferred_time_slot,
  confidence_score, inventory_checked, inventory_ok,
  created_at, updated_at,
  client:clients(id, name, phone, email, region, comuna, address),
  animal:animals(id, name, species, breed, sex, weight_kg),
  assigned:users(id, name)
`

export const leadsService = {
  async getAll(filters = {}) {
    let q = supabase.from('leads').select(LEAD_SELECT).order('created_at', { ascending: false })
    if (filters.status)      q = q.eq('status', filters.status)
    if (filters.assigned_to) q = q.eq('assigned_to', filters.assigned_to)
    const { data, error } = await q
    if (error) throw error
    return data
  },

  async getById(id) {
    const { data, error } = await supabase
      .from('leads').select(LEAD_SELECT).eq('id', id).single()
    if (error) throw error
    return data
  },

  async updateStatus(id, newStatus, note = '') {
    const { data, error } = await supabase
      .from('leads').update({ status: newStatus, updated_at: new Date().toISOString() })
      .eq('id', id).select().single()
    if (error) throw error
    // El trigger DB log_lead_status_change (004_triggers.sql) inserta en lead_status_history automáticamente
    return data
  },

  async create(payload) {
    const { data, error } = await supabase
      .from('leads').insert(payload).select().single()
    if (error) throw error
    return data
  },

  async update(id, payload) {
    const { data, error } = await supabase
      .from('leads').update({ ...payload, updated_at: new Date().toISOString() }).eq('id', id).select().single()
    if (error) throw error
    return data
  },

  async getHistory(leadId) {
    const { data, error } = await supabase
      .from('lead_status_history').select('*').eq('lead_id', leadId).order('created_at')
    if (error) throw error
    return data
  },
}
