import { supabase } from './supabase.js'

export const usersService = {
  async updateProfile(id, payload) {
    const { data, error } = await supabase
      .from('users').update(payload).eq('id', id).select().single()
    if (error) throw error
    return data
  },
}
