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
      <!-- Header -->
      <div class="text-center mb-8">
        <span role="img" aria-label="VetDesk" class="text-4xl mb-3 block">🐾</span>
        <h2 class="text-2xl font-semibold text-[var(--text-primary)] mb-2">Mi Mascota</h2>
        <p class="text-sm text-[var(--text-muted)]">Busca el expediente de tu mascota</p>
      </div>

      <!-- Toggle -->
      <div class="flex rounded-lg bg-[var(--bg-secondary)] p-1 mb-6">
        <button
          type="button"
          @click="searchMode = 'rut'; error = ''"
          :class="['flex-1 py-2 px-4 rounded-md text-sm font-medium transition-all', searchMode === 'rut' ? 'bg-[var(--btn-primary-bg)] text-white' : 'text-[var(--text-muted)] hover:text-[var(--text-primary)]']"
        >
          <span aria-hidden="true">🔍</span> Buscar por RUT
        </button>
        <button
          type="button"
          @click="searchMode = 'phone'; error = ''"
          :class="['flex-1 py-2 px-4 rounded-md text-sm font-medium transition-all', searchMode === 'phone' ? 'bg-[var(--btn-primary-bg)] text-white' : 'text-[var(--text-muted)] hover:text-[var(--text-primary)]']"
        >
          <span aria-hidden="true">📱</span> Buscar por Teléfono
        </button>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <!-- RUT input -->
        <div v-if="searchMode === 'rut'">
          <label class="block text-sm text-[var(--text-muted)] mb-1.5">RUT del dueño</label>
          <input
            v-model="rutInput"
            type="text"
            placeholder="12.345.678-9"
            class="input-base w-full"
            autocomplete="off"
          />
          <p v-if="rutError" class="text-xs mt-1" style="color: var(--text-error)">{{ rutError }}</p>
        </div>

        <!-- Phone input -->
        <div v-else>
          <label class="block text-sm text-[var(--text-muted)] mb-1.5">Teléfono registrado</label>
          <input
            v-model="phoneInput"
            type="tel"
            placeholder="+56 9 1234 5678"
            class="input-base w-full"
            autocomplete="tel"
          />
          <p v-if="phoneError" class="text-xs mt-1" style="color: var(--text-error)">{{ phoneError }}</p>
        </div>

        <!-- Error -->
        <p v-if="error" class="text-sm text-center" style="color: var(--text-error)">{{ error }}</p>

        <!-- Submit -->
        <button type="submit" class="btn-primary w-full justify-center" :disabled="loading">
          <span v-if="loading">Buscando...</span>
          <span v-else>Buscar</span>
        </button>
      </form>

      <!-- Link to request -->
      <div class="mt-6 text-center">
        <p class="text-xs text-[var(--text-muted)]">
          ¿No tienes cuenta?
          <RouterLink to="/solicitar" class="text-[var(--btn-primary-bg)] hover:opacity-80 transition-opacity">
            Solicitar una visita →
          </RouterLink>
        </p>
      </div>
    </div>
  </div>
</template>
