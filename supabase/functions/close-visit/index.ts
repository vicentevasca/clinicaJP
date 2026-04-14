import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

// TODO: Implementar Edge Function close-visit
serve(async (req) => {
  return new Response(JSON.stringify({ message: 'close-visit — por implementar' }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
