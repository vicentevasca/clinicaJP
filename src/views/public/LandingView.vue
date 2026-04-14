<script setup>
import { RouterLink } from 'vue-router'
</script>
<template>
  <div class="min-h-screen flex flex-col items-center justify-center px-4 text-center">
    <h1 class="text-5xl font-bold text-white mb-4">🐾 VetDesk</h1>
    <p class="text-xl text-slate-400 mb-8 max-w-lg">
      Atención veterinaria a domicilio. Rápida, confiable y sin complicaciones.
    </p>
    <RouterLink to="/solicitar" class="btn-primary text-lg px-8 py-3">
      Solicitar visita
    </RouterLink>
  </div>
</template>
