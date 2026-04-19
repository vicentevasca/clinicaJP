<script setup>
import { ref, computed, onMounted } from 'vue'
import { isValidRUT, normalizeRUT } from '@/utils/validators'
import { isValidChilePhone } from '@/utils/validators'
import { gsap } from 'gsap'

const emit = defineEmits(['search'])

const searchMode = ref('rut') // 'rut' | 'phone'
const rutInput = ref('')
const phoneInput = ref('')
const loading = ref(false)
const error = ref('')

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

onMounted(() => {
  if (prefersReducedMotion) return
  gsap.from('.animate-in', { opacity: 0, y: 20, stagger: 0.12, duration: 0.5, delay: 0.1 })
})

const rutError = computed(() => {
  if (!rutInput.value || searchMode.value !== 'rut') return ''
  return isValidRUT(rutInput.value) ? '' : 'RUT inválido'
})

const phoneError = computed(() => {
  if (!phoneInput.value || searchMode.value !== 'phone') return ''
  return isValidChilePhone(phoneInput.value) ? '' : 'Teléfono inválido'
})

async function handleSubmit() {
  error.value = ''
  if (searchMode.value === 'rut') {
    if (!rutInput.value) { error.value = 'Ingresa tu RUT'; return }
    if (!isValidRUT(rutInput.value)) { error.value = 'RUT inválido'; return }
    emit('search', { type: 'rut', value: normalizeRUT(rutInput.value) })
  } else {
    if (!phoneInput.value) { error.value = 'Ingresa tu teléfono'; return }
    if (!isValidChilePhone(phoneInput.value)) { error.value = 'Teléfono inválido'; return }
    const clean = phoneInput.value.replace(/\D/g, '')
    const normalized = clean.startsWith('56') ? '+' + clean : '+56' + clean
    emit('search', { type: 'phone', value: normalized })
  }
}
</script>

<template>
  <div class="w-full max-w-md mx-auto">
    <div class="card p-8 animate-in">

      <!-- Form header -->
      <div class="text-center mb-8">
        <h2 class="text-2xl font-bold mb-1.5" style="color: var(--text-primary);">
          Busca tu mascota
        </h2>
        <p class="text-sm" style="color: var(--text-muted);">
          Ingresa tu RUT o teléfono para acceder al expediente
        </p>
      </div>

      <!-- Segmented control toggle -->
      <div
        class="flex rounded-xl p-1 mb-6"
        style="background-color: var(--bg-secondary); border: 1px solid var(--border-color);"
      >
        <button
          type="button"
          @click="searchMode = 'rut'; error = ''"
          :class="['flex-1 py-2 px-3 rounded-lg text-sm font-semibold transition-all duration-200 flex items-center justify-center gap-1.5']"
          :style="searchMode === 'rut'
            ? 'background-color: var(--btn-primary-bg); color: #fff; box-shadow: 0 1px 4px var(--btn-primary-shadow);'
            : 'background-color: transparent; color: var(--text-muted);'"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35m0 0A7.5 7.5 0 104.5 4.5a7.5 7.5 0 0012.15 12.15z" />
          </svg>
          Buscar por RUT
        </button>
        <button
          type="button"
          @click="searchMode = 'phone'; error = ''"
          :class="['flex-1 py-2 px-3 rounded-lg text-sm font-semibold transition-all duration-200 flex items-center justify-center gap-1.5']"
          :style="searchMode === 'phone'
            ? 'background-color: var(--btn-primary-bg); color: #fff; box-shadow: 0 1px 4px var(--btn-primary-shadow);'
            : 'background-color: transparent; color: var(--text-muted);'"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 1.5H8.25A2.25 2.25 0 006 3.75v16.5a2.25 2.25 0 002.25 2.25h7.5A2.25 2.25 0 0018 20.25V3.75a2.25 2.25 0 00-2.25-2.25H13.5m-3 0V3h3V1.5m-3 0h3m-3 8.25h3" />
          </svg>
          Por Teléfono
        </button>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleSubmit" class="space-y-4">

        <!-- RUT input -->
        <div v-if="searchMode === 'rut'">
          <label class="label-base mb-1.5 block">RUT del dueño</label>
          <div class="relative">
            <span
              class="absolute left-3 top-1/2 -translate-y-1/2 text-base pointer-events-none select-none"
              aria-hidden="true"
            >🔍</span>
            <input
              v-model="rutInput"
              type="text"
              placeholder="Ej: 12.345.678-9"
              class="input-base w-full pl-9"
              autocomplete="off"
            />
          </div>
          <p v-if="rutError" class="text-xs mt-1" style="color: var(--text-error);">{{ rutError }}</p>
        </div>

        <!-- Phone input -->
        <div v-else>
          <label class="label-base mb-1.5 block">Teléfono registrado</label>
          <div class="relative">
            <span
              class="absolute left-3 top-1/2 -translate-y-1/2 text-base pointer-events-none select-none"
              aria-hidden="true"
            >📱</span>
            <input
              v-model="phoneInput"
              type="tel"
              placeholder="Ej: +56 9 8765 4321"
              class="input-base w-full pl-9"
              autocomplete="tel"
            />
          </div>
          <p v-if="phoneError" class="text-xs mt-1" style="color: var(--text-error);">{{ phoneError }}</p>
        </div>

        <!-- General error -->
        <p v-if="error" class="text-sm text-center" style="color: var(--text-error);">{{ error }}</p>

        <!-- Submit -->
        <button type="submit" class="btn-primary w-full justify-center" :disabled="loading">
          <span v-if="loading" class="flex items-center gap-2">
            <span class="spinner w-4 h-4"></span>
            Buscando...
          </span>
          <span v-else>Buscar expediente</span>
        </button>
      </form>

      <!-- Link to request -->
      <div class="mt-6 text-center">
        <p class="text-xs" style="color: var(--text-muted);">
          ¿Primera vez?
          <RouterLink
            to="/solicitar"
            class="font-semibold transition-opacity hover:opacity-75"
            style="color: var(--btn-primary-bg);"
          >
            Solicitar una visita →
          </RouterLink>
        </p>
      </div>

    </div>
  </div>
</template>
