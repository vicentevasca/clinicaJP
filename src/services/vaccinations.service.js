import { supabase } from './supabase.js'

export const vaccinationsService = {
  async getByAnimalId(animalId) {
    const { data, error } = await supabase
      .from('vaccinations')
      .select('*, created_by_user:users(name)')
      .eq('animal_id', animalId)
      .order('administered_at', { ascending: false })
    if (error) throw error
    return data
  },

  async getByVisitId(visitId) {
    const { data, error } = await supabase
      .from('vaccinations')
      .select('*')
      .eq('visit_id', visitId)
      .order('administered_at', { ascending: false })
    if (error) throw error
    return data
  },

  async create(payload) {
    const { data, error } = await supabase
      .from('vaccinations').insert(payload).select().single()
    if (error) throw error
    return data
  },

  async update(id, payload) {
    const { data, error } = await supabase
      .from('vaccinations').update(payload).eq('id', id).select().single()
    if (error) throw error
    return data
  },

  async remove(id) {
    const { error } = await supabase
      .from('vaccinations').delete().eq('id', id)
    if (error) throw error
  },
}
