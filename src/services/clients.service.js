import { supabase } from '@/services/supabase.js'

const PORTAL_SECRET = import.meta.env.VITE_PORTAL_API_SECRET || 'vetdesk_portal_secret'
const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY

async function portalFetch(functionName, params = {}) {
  const query = new URLSearchParams(params).toString()
  const url = `${SUPABASE_URL}/functions/v1/${functionName}${query ? '?' + query : ''}`
  const res = await fetch(url, {
    headers: {
      'Content-Type': 'application/json',
      'X-Api-Secret': PORTAL_SECRET,
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
    },
  })
  const data = await res.json()
  if (!res.ok) throw new Error(data.error || 'Error en portal')
  return data
}

export const clientsService = {
  async findByRut(rut) {
    return portalFetch('get-client-portal-data', { rut })
  },

  async findByPhone(phone) {
    return portalFetch('get-client-portal-data', { phone })
  },
}
