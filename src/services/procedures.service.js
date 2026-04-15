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

  async getLinkedInventory(procedureId) {
    const { data, error } = await supabase
      .from('procedure_inventory').select(`
        quantity, notes,
        inventory:inventory(id, name, stock, min_stock, unit)
      `).eq('procedure_id', procedureId)
    if (error) throw error
    return data
  },

  async saveLinkedInventory(procedureId, items) {
    // items: Array<{ inventory_id, quantity, notes }>
    // Eliminar vínculos existentes
    await supabase.from('procedure_inventory').delete().eq('procedure_id', procedureId)
    // Insertar nuevos
    if (items.length > 0) {
      const rows = items.map(i => ({
        procedure_id: procedureId,
        inventory_id: i.inventory_id,
        quantity: i.quantity || 1,
        notes: i.notes || null,
      }))
      const { error } = await supabase.from('procedure_inventory').insert(rows)
      if (error) throw error
    }
  },
}
