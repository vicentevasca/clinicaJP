import { supabase } from './supabase.js'

export const inventoryService = {
  async getAll() {
    const { data, error } = await supabase
      .from('inventory').select('*').eq('active', true).order('name')
    if (error) throw error
    return data
  },

  async getLowStock() {
    const { data, error } = await supabase
      .from('inventory').select('*').eq('active', true)
    if (error) throw error
    return (data || []).filter(item => item.stock <= item.min_stock)
  },

  async upsert(payload) {
    const { data, error } = await supabase
      .from('inventory').upsert(payload).select().single()
    if (error) throw error
    return data
  },
}
