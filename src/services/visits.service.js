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
}
