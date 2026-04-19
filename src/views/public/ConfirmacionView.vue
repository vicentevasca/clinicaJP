<script setup>
import { onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { gsap } from 'gsap'

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

onMounted(() => {
  if (prefersReducedMotion) return
  gsap.from('.animate-in', { opacity: 0, scale: 0.9, stagger: 0.15, duration: 0.5, delay: 0.1 })
})
</script>

<template>
  <div class="min-h-screen pt-16 bg-[var(--bg-primary)] flex items-center justify-center px-4">
    <div class="max-w-md w-full text-center">
      <div class="animate-in mb-8">
        <div
          role="img"
          aria-label="Solicitud recibida"
          class="w-24 h-24 rounded-full bg-[var(--brand-alpha)] border border-[var(--border-color)] flex items-center justify-center mx-auto mb-6"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="w-12 h-12 text-[var(--btn-primary-bg)]" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
          </svg>
        </div>
      </div>
      <h1 class="text-3xl sm:text-4xl font-bold text-[var(--text-primary)] mb-4 animate-in">
        ¡Solicitud<br />
        <span class="text-[var(--btn-primary-bg)]">recibida!</span>
      </h1>
      <p class="text-[var(--text-secondary)] mb-6 leading-relaxed animate-in">
        Hemos recibido tu solicitud de atención. Nuestro equipo se pondrá en contacto contigo a la brevedad para confirmar la fecha y hora de la visita.
      </p>

      <div class="card p-5 mb-8 text-left animate-in">
        <h3 class="text-sm font-semibold text-[var(--text-secondary)] mb-3">¿Qué sigue?</h3>
        <div class="space-y-3">
          <div class="flex items-start gap-3">
            <span class="w-6 h-6 rounded-full bg-[var(--brand-alpha)] text-[var(--btn-primary-bg)] text-xs flex items-center justify-center flex-shrink-0 mt-0.5">1</span>
            <p class="text-sm text-[var(--text-muted)]">Te contactamos por WhatsApp o llamada en menos de 2 horas hábiles</p>
          </div>
          <div class="flex items-start gap-3">
            <span class="w-6 h-6 rounded-full bg-[var(--brand-alpha)] text-[var(--btn-primary-bg)] text-xs flex items-center justify-center flex-shrink-0 mt-0.5">2</span>
            <p class="text-sm text-[var(--text-muted)]">Confirmamos la dirección y agendamos la visita</p>
          </div>
          <div class="flex items-start gap-3">
            <span class="w-6 h-6 rounded-full bg-[var(--brand-alpha)] text-[var(--btn-primary-bg)] text-xs flex items-center justify-center flex-shrink-0 mt-0.5">3</span>
            <p class="text-sm text-[var(--text-muted)]">Llegamos a tu domicilio con todo lo necesario</p>
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
