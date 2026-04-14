import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

// TODO: Implementar Edge Function telegram-webhook
serve(async (req) => {
  return new Response(JSON.stringify({ message: 'telegram-webhook — por implementar' }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
