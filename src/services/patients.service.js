import { supabase } from './supabase.js'

export const patientsService = {
  async getAnimals(filters = {}) {
    let q = supabase.from('animals').select(`
      *, client:clients(id, name, phone, email)
    `).order('name')
    if (filters.client_id) q = q.eq('client_id', filters.client_id)
    if (filters.species)   q = q.eq('species', filters.species)
    const { data, error } = await q
    if (error) throw error
    return data
  },

  async getAnimalById(id) {
    const { data, error } = await supabase.from('animals').select(`
      *, client:clients(*),
      clinical_records(*, visit:visits(scheduled_at, status))
    `).eq('id', id).single()
    if (error) throw error
    return data
  },

  async getClients() {
    const { data, error } = await supabase
      .from('clients').select('*, animals(id, name, species)').order('name')
    if (error) throw error
    return data
  },

  async updateWeight(animalId, weightKg) {
    const { error } = await supabase
      .from('animals')
      .update({ weight_kg: weightKg, updated_at: new Date().toISOString() })
      .eq('id', animalId)
    if (error) throw error
  },
}
