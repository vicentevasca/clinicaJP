<script setup>
import { ref, computed } from 'vue'
import { isValidRUT, normalizeRUT } from '@/utils/validators'
import { isValidChilePhone } from '@/utils/validators'

const emit = defineEmits(['search'])

const searchMode = ref('rut') // 'rut' | 'phone'
const rutInput = ref('')
const phoneInput = ref('')
const loading = ref(false)
const error = ref('')

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
    <div class="card p-8">
      <!-- Header -->
      <div class="text-center mb-8">
        <span class="text-4xl mb-3 block">🐾</span>
        <h2 class="text-2xl font-bold text-white mb-2">Mi Mascota</h2>
        <p class="text-sm text-slate-400">Busca el expediente de tu mascota</p>
      </div>

      <!-- Toggle -->
      <div class="flex rounded-lg bg-slate-800 p-1 mb-6">
        <button
          type="button"
          @click="searchMode = 'rut'; error = ''"
          :class="['flex-1 py-2 px-4 rounded-md text-sm font-medium transition-all', searchMode === 'rut' ? 'bg-brand-600 text-white' : 'text-slate-400 hover:text-white']"
        >
          🔍 Buscar por RUT
        </button>
        <button
          type="button"
          @click="searchMode = 'phone'; error = ''"
          :class="['flex-1 py-2 px-4 rounded-md text-sm font-medium transition-all', searchMode === 'phone' ? 'bg-brand-600 text-white' : 'text-slate-400 hover:text-white']"
        >
          📱 Buscar por Teléfono
        </button>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <!-- RUT input -->
        <div v-if="searchMode === 'rut'">
          <label class="block text-sm text-slate-400 mb-1.5">RUT del dueño</label>
          <input
            v-model="rutInput"
            type="text"
            placeholder="12.345.678-9"
            class="input w-full"
            autocomplete="off"
          />
          <p v-if="rutError" class="text-red-400 text-xs mt-1">{{ rutError }}</p>
        </div>

        <!-- Phone input -->
        <div v-else>
          <label class="block text-sm text-slate-400 mb-1.5">Teléfono registrado</label>
          <input
            v-model="phoneInput"
            type="tel"
            placeholder="+56 9 1234 5678"
            class="input w-full"
            autocomplete="tel"
          />
          <p v-if="phoneError" class="text-red-400 text-xs mt-1">{{ phoneError }}</p>
        </div>

        <!-- Error -->
        <p v-if="error" class="text-red-400 text-sm text-center">{{ error }}</p>

        <!-- Submit -->
        <button type="submit" class="btn-primary w-full justify-center" :disabled="loading">
          <span v-if="loading">Buscando...</span>
          <span v-else>🔍 Buscar</span>
        </button>
      </form>

      <!-- Link to request -->
      <div class="mt-6 text-center">
        <p class="text-xs text-slate-500">
          ¿No tienes cuenta?
          <RouterLink to="/solicitar" class="text-brand-400 hover:text-brand-300 transition-colors">
            Solicitar una visita →
          </RouterLink>
        </p>
      </div>
    </div>
  </div>
</template>
