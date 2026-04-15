<script setup>
import { ref } from 'vue'
import { portalService } from '@/services/portal.service'
import BaseModal from '@/components/ui/BaseModal.vue'

const props = defineProps({
  client: { type: Object, required: true },
  animal: { type: Object, required: true },
  show: { type: Boolean, default: false },
})

const emit = defineEmits(['close', 'success'])

const serviceOptions = [
  { value: 'vacunacion', label: '💉 Vacunación' },
  { value: 'desparasitacion', label: '💊 Desparasitación' },
  { value: 'chequeo', label: '🩺 Chequeo general' },
  { value: 'receta', label: '📋 Receta médica' },
  { value: 'corte_pelo', label: '✂️ Corte de pelo' },
  { value: 'atencion_domicilio', label: '🏠 Atención a domicilio' },
  { value: 'otro', label: '❓ Otro' },
]

const step = ref('form') // 'form' | 'success'

const form = ref({
  service_type: '',
  description: '',
})

const loading = ref(false)
const error = ref('')

async function handleSubmit() {
  if (!form.value.service_type || !form.value.description.trim()) return
  loading.value = true
  error.value = ''
  try {
    await portalService.createConsultationRequest({
      client_id: props.client.id,
      animal_id: props.animal.id,
      service_type: form.value.service_type,
      description: form.value.description,
    })
    step.value = 'success'
    emit('success')
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

function handleClose() {
  step.value = 'form'
  form.value = { service_type: '', description: '' }
  emit('close')
}
</script>

<template>
  <BaseModal size="md" :show="show" @close="handleClose">
    <!-- Success state -->
    <div v-if="step === 'success'" class="text-center py-6">
      <div class="text-5xl mb-4">✅</div>
      <h3 class="text-xl font-bold text-white mb-2">¡Solicitud enviada!</h3>
      <p class="text-slate-400 text-sm mb-6">
        Hemos recibido tu solicitud para <strong class="text-white">{{ animal.name }}</strong>.
        Te contactaremos a la brevedad para coordinar la visita.
      </p>
      <button type="button" @click="handleClose" class="btn-primary w-full justify-center">
        Entendido
      </button>
    </div>

    <!-- Form state -->
    <template v-else>
      <div class="flex items-center justify-between mb-5">
        <div>
          <h3 class="text-lg font-semibold text-white">Nueva consulta</h3>
          <p class="text-sm text-slate-400">para {{ animal.name }}</p>
        </div>
        <button type="button" @click="handleClose" class="text-slate-400 hover:text-white transition-colors text-xl">✕</button>
      </div>

      <!-- Pet profile summary (read-only) -->
      <div class="flex items-center gap-3 p-3 rounded-lg bg-slate-800/60 border border-slate-700/50 mb-5">
        <div class="w-10 h-10 rounded-full bg-brand-600/20 flex items-center justify-center text-xl flex-shrink-0">
          {{ { perro: '🐕', gato: '🐈', ave: '🐦', gallina: '🐔', caballo: '🐴', bovino: '🐄', otro: '🐾' }[animal.species] || '🐾' }}
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-white">{{ animal.name }}</p>
          <p class="text-xs text-slate-400 capitalize">
            {{ animal.species }}{{ animal.breed ? ` · ${animal.breed}` : '' }}
            <span v-if="animal.sex"> · {{ animal.sex }}</span>
          </p>
        </div>
        <div class="text-right hidden sm:block">
          <p class="text-xs text-slate-500">{{ client.name }}</p>
          <p class="text-xs text-slate-600">{{ client.phone }}</p>
        </div>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-slate-300 mb-1.5">¿Qué necesitas?</label>
          <select v-model="form.service_type" class="input w-full">
            <option value="" disabled>Selecciona un servicio</option>
            <option v-for="opt in serviceOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
          </select>
        </div>

        <div>
          <textarea
            v-model="form.description"
            rows="3"
            placeholder="Cuéntanos qué necesita tu mascota..."
            class="input w-full resize-none"
          />
        </div>

        <p v-if="error" class="text-red-400 text-sm text-center">{{ error }}</p>

        <button type="submit" class="btn-primary w-full justify-center" :disabled="loading || !form.service_type || !form.description.trim()">
          {{ loading ? 'Enviando...' : '✅ Confirmar solicitud' }}
        </button>
      </form>
    </template>
  </BaseModal>
</template>
