import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

// TODO: Implementar Edge Function send-email
serve(async (req) => {
  return new Response(JSON.stringify({ message: 'send-email — por implementar' }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
