import { supabase } from './supabase.js'

export const visitsService = {
  async getByRange(from, to) {
    const { data, error } = await supabase
      .from('visits')
      .select(`*, client:clients(name,phone), animal:animals(name,species), assigned:users(name)`)
      .gte('scheduled_at', from).lte('scheduled_at', to)
      .order('scheduled_at')
    if (error) throw error
    return data
  },

  async getById(id) {
    const { data, error } = await supabase
      .from('visits').select(`
        *, client:clients(*), animal:animals(*), assigned:users(name),
        visit_procedures(*, procedure:procedures(*)),
        clinical_records(*)
      `).eq('id', id).single()
    if (error) throw error
    return data
  },

  async updateStatus(id, status) {
    const { data, error } = await supabase
      .from('visits').update({ status }).eq('id', id).select().single()
    if (error) throw error
    return data
  },

  async getByLeadId(leadId) {
    const { data, error } = await supabase
      .from('visits').select('*, client:clients(name,phone), animal:animals(name)')
      .eq('lead_id', leadId).maybeSingle()
    if (error) throw error
    return data
  },

  async create(payload) {
    const { data, error } = await supabase
      .from('visits').insert(payload).select().single()
    if (error) throw error
    return data
  },

  async update(id, payload) {
    const { data, error } = await supabase
      .from('visits').update({ ...payload, updated_at: new Date().toISOString() })
      .eq('id', id).select().single()
    if (error) throw error
    return data
  },
}
