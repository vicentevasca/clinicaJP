import { supabase } from '@/services/supabase.js'

const PORTAL_SECRET = import.meta.env.VITE_PORTAL_API_SECRET || 'vetdesk_portal_secret'
const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY

export const portalService = {
  async createConsultationRequest(payload) {
    const url = `${SUPABASE_URL}/functions/v1/create-consultation-request`
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Secret': PORTAL_SECRET,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify(payload),
    })
    const data = await res.json()
    if (!res.ok) throw new Error(data.error || 'Error al crear solicitud')
    return data
  },
}
