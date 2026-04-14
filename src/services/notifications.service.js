// Llama a Edge Functions de Supabase (no a APIs externas directamente)
import { supabase } from './supabase.js'

export const notificationsService = {
  async getWhatsAppPreview(leadId, template = 'initial_contact') {
    const { data, error } = await supabase.functions.invoke('whatsapp-preview', {
      body: { lead_id: leadId, template }
    })
    if (error) throw error
    return data
  },
}
