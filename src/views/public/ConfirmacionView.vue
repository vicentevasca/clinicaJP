<script setup>
import { RouterLink } from 'vue-router'
</script>
<template>
  <div class="min-h-screen flex items-center justify-center px-4 text-center">
    <div class="max-w-md">
      <div class="text-6xl mb-6">✅</div>
      <h1 class="text-3xl font-bold text-white mb-3">¡Solicitud enviada!</h1>
      <p class="text-slate-400 mb-8">
        Recibimos tu solicitud. Nos pondremos en contacto contigo a la brevedad.
      </p>
      <RouterLink to="/" class="btn-secondary">Volver al inicio</RouterLink>
    </div>
  </div>
</template>
