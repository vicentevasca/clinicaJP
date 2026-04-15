import { supabase } from './supabase.js'

export const inventoryService = {
  async getAll() {
    const { data, error } = await supabase
      .from('inventory').select('*').eq('active', true).order('name')
    if (error) throw error
    return data
  },

  async getLowStock() {
    // Note: accurate low-stock requires comparing stock vs min_stock per row
    // The inventoryStore uses a JS computed filter instead
    const { data, error } = await supabase
      .from('inventory').select('*')
      .eq('active', true)
      .lte('stock', 0)
    if (error) throw error
    return data
  },

  async upsert(payload) {
    const { data, error } = await supabase
      .from('inventory').upsert(payload).select().single()
    if (error) throw error
    return data
  },
}
