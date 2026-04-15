import { supabase } from './supabase.js'

export const clinicalService = {
  async create(payload) {
    const { data, error } = await supabase
      .from('clinical_records').insert(payload).select().single()
    if (error) throw error
    return data
  },

  async update(id, payload) {
    const { data, error } = await supabase
      .from('clinical_records').update(payload).eq('id', id).select().single()
    if (error) throw error
    return data
  },
}
