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
  <div
    class="min-h-screen pt-16"
    style="background-color: var(--bg-primary);"
  >
    <div class="flex items-center justify-center px-4 py-16">
      <div class="max-w-md w-full mx-auto">

        <!-- Success icon -->
        <div class="animate-in flex flex-col items-center mb-8">
          <div
            class="w-24 h-24 rounded-full flex items-center justify-center mb-6"
            style="background-color: var(--brand-alpha); border: 2px solid var(--border-color);"
          >
            <div
              class="w-16 h-16 rounded-full flex items-center justify-center"
              style="background-color: var(--btn-primary-bg);"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="w-8 h-8"
                fill="none"
                viewBox="0 0 24 24"
                stroke="white"
                stroke-width="2.5"
                aria-hidden="true"
              >
                <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
              </svg>
            </div>
          </div>

          <!-- Headline -->
          <h1 class="text-3xl sm:text-4xl font-bold text-center mb-3" style="color: var(--text-primary);">
            ¡Tu solicitud fue enviada!
          </h1>
          <p class="text-center text-base" style="color: var(--text-secondary);">
            Nos contactaremos contigo pronto.
          </p>
        </div>

        <!-- "¿Qué sigue?" card -->
        <div class="card p-6 mb-8 animate-in">
          <h3
            class="text-sm font-semibold uppercase tracking-wide mb-5"
            style="color: var(--text-muted);"
          >
            ¿Qué sigue?
          </h3>

          <div class="space-y-5">
            <!-- Step 1 -->
            <div class="flex items-start gap-4">
              <span
                class="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0 text-xs font-bold text-white mt-0.5"
                style="background-color: var(--btn-primary-bg);"
              >1</span>
              <div>
                <p class="text-sm font-semibold mb-0.5" style="color: var(--text-primary);">
                  Te contactamos
                </p>
                <p class="text-sm" style="color: var(--text-muted);">
                  Recibirás una llamada o WhatsApp en menos de 2 horas hábiles
                </p>
              </div>
            </div>

            <!-- Divider -->
            <div class="ml-3.5 pl-8 border-l" style="border-color: var(--border-color);"></div>

            <!-- Step 2 -->
            <div class="flex items-start gap-4">
              <span
                class="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0 text-xs font-bold text-white mt-0.5"
                style="background-color: var(--btn-primary-bg);"
              >2</span>
              <div>
                <p class="text-sm font-semibold mb-0.5" style="color: var(--text-primary);">
                  Coordinamos la visita
                </p>
                <p class="text-sm" style="color: var(--text-muted);">
                  Confirmamos dirección, horario y lo que necesita tu mascota
                </p>
              </div>
            </div>

            <!-- Divider -->
            <div class="ml-3.5 pl-8 border-l" style="border-color: var(--border-color);"></div>

            <!-- Step 3 -->
            <div class="flex items-start gap-4">
              <span
                class="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0 text-xs font-bold text-white mt-0.5"
                style="background-color: var(--btn-primary-bg);"
              >3</span>
              <div>
                <p class="text-sm font-semibold mb-0.5" style="color: var(--text-primary);">
                  ¡Llegamos a tu casa!
                </p>
                <p class="text-sm" style="color: var(--text-muted);">
                  El técnico veterinario llega con todo el equipamiento necesario
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="animate-in flex flex-col sm:flex-row gap-3 justify-center">
          <RouterLink to="/solicitar" class="btn-secondary text-center">
            Nueva solicitud
          </RouterLink>
          <RouterLink to="/" class="btn-primary text-center">
            Volver al inicio
          </RouterLink>
        </div>

      </div>
    </div>
  </div>
</template>
