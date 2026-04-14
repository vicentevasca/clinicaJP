import { supabase } from './supabase.js'

export const proceduresService = {
  async getAll() {
    const { data, error } = await supabase
      .from('procedures').select(`
        *,
        procedure_inventory(
          inventory:inventory(id, name, stock, min_stock, unit)
        )
      `).eq('active', true).order('name')
    if (error) throw error
    return data
  },

  async upsert(payload) {
    const { data, error } = await supabase
      .from('procedures').upsert(payload).select().single()
    if (error) throw error
    return data
  },

  async delete(id) {
    const { error } = await supabase
      .from('procedures').update({ active: false }).eq('id', id)
    if (error) throw error
  },
}
