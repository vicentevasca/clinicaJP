<script setup>
import { onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { gsap } from 'gsap'

onMounted(() => {
  gsap.from('.animate-in', { opacity: 0, scale: 0.9, stagger: 0.15, duration: 0.5, delay: 0.1 })
})
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 flex items-center justify-center px-4">
    <div class="max-w-md w-full text-center">
      <div class="animate-in mb-8">
        <div class="w-24 h-24 rounded-full bg-brand-500/20 border-2 border-brand-500/30 flex items-center justify-center mx-auto mb-6">
          <span class="text-5xl">🐾</span>
        </div>
      </div>
      <h1 class="text-3xl sm:text-4xl font-bold text-white mb-4 animate-in">
        ¡Solicitud<br />
        <span class="text-brand-400">recibida!</span>
      </h1>
      <p class="text-slate-400 mb-6 leading-relaxed animate-in">
        Hemos recibido tu solicitud de atención. Nuestro equipo se pondrá en contacto contigo a la brevedad para confirmar la fecha y hora de la visita.
      </p>

      <div class="card p-5 mb-8 text-left animate-in">
        <h3 class="text-sm font-semibold text-slate-300 mb-3">¿Qué sigue?</h3>
        <div class="space-y-3">
          <div class="flex items-start gap-3">
            <span class="w-6 h-6 rounded-full bg-brand-500/20 text-brand-400 text-xs flex items-center justify-center flex-shrink-0 mt-0.5">1</span>
            <p class="text-sm text-slate-400">Te contactamos por WhatsApp o llamada en menos de 2 horas hábiles</p>
          </div>
          <div class="flex items-start gap-3">
            <span class="w-6 h-6 rounded-full bg-brand-500/20 text-brand-400 text-xs flex items-center justify-center flex-shrink-0 mt-0.5">2</span>
            <p class="text-sm text-slate-400">Confirmamos la dirección y agendamos la visita</p>
          </div>
          <div class="flex items-start gap-3">
            <span class="w-6 h-6 rounded-full bg-brand-500/20 text-brand-400 text-xs flex items-center justify-center flex-shrink-0 mt-0.5">3</span>
            <p class="text-sm text-slate-400">Llegamos a tu domicilio con todo lo necesario</p>
          </div>
        </div>
      </div>

      <div class="flex flex-col sm:flex-row gap-3 justify-center animate-in">
        <RouterLink to="/solicitar" class="btn-secondary">
          Nueva solicitud
        </RouterLink>
        <RouterLink to="/" class="btn-primary">
          Volver al inicio
        </RouterLink>
      </div>
    </div>
  </div>
</template>
