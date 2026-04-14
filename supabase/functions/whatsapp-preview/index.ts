import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

// TODO: Implementar Edge Function whatsapp-preview
serve(async (req) => {
  return new Response(JSON.stringify({ message: 'whatsapp-preview — por implementar' }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
