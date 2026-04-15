<script setup>
import { ref, computed } from 'vue'
import { portalService } from '@/services/portal.service'
import SlotCalendar from './SlotCalendar.vue'
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

const form = ref({
  service_type: '',
  description: '',
  priority: 'normal',
  preferred_date: null,
  preferred_time_slot: null,
})

const loading = ref(false)
const error = ref('')

const selectedSlot = computed({
  get: () => ({ date: form.value.preferred_date, time_slot: form.value.preferred_time_slot }),
  set: (val) => {
    form.value.preferred_date = val?.date || null
    form.value.preferred_time_slot = val?.time_slot || null
  },
})

const isValid = computed(() =>
  form.value.service_type &&
  form.value.description.trim().length >= 10 &&
  form.value.preferred_date &&
  form.value.preferred_time_slot
)

async function handleSubmit() {
  if (!isValid.value) return
  loading.value = true
  error.value = ''
  try {
    await portalService.createConsultationRequest({
      client_id: props.client.id,
      animal_id: props.animal.id,
      service_type: form.value.service_type,
      description: form.value.description,
      priority: form.value.priority,
      preferred_date: form.value.preferred_date,
      preferred_time_slot: form.value.preferred_time_slot,
    })
    emit('success')
    emit('close')
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <BaseModal :show="show" title="Nueva consulta" size="lg" @close="$emit('close')">
    <p class="text-sm text-slate-400 mb-5">{{ animal.name }} · {{ client.name }}</p>

    <!-- Form -->
    <form @submit.prevent="handleSubmit" class="space-y-5">
      <!-- Service type -->
      <div>
        <label class="block text-sm text-slate-400 mb-1.5">Tipo de servicio *</label>
        <select v-model="form.service_type" class="input w-full">
          <option value="" disabled>Selecciona un servicio</option>
          <option v-for="opt in serviceOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
        </select>
      </div>

      <!-- Description -->
      <div>
        <label class="block text-sm text-slate-400 mb-1.5">Descripción del caso *</label>
        <textarea
          v-model="form.description"
          rows="3"
          placeholder="Cuéntanos qué necesita tu mascota..."
          class="input w-full resize-none"
        />
        <p class="text-xs text-slate-600 mt-1">Mínimo 10 caracteres</p>
      </div>

      <!-- Priority -->
      <div>
        <label class="block text-sm text-slate-400 mb-1.5">Urgencia</label>
        <div class="flex gap-3">
          <label v-for="p in [{value:'low',label:'Baja'},{value:'normal',label:'Normal'},{value:'high',label:'Alta'},{value:'urgent',label:'Urgente'}]" :key="p.value"
            :class="['flex items-center gap-2 cursor-pointer px-3 py-2 rounded-lg border text-sm transition-all cursor-pointer',
              form.priority === p.value ? 'border-brand-500 bg-brand-500/10 text-brand-400' : 'border-slate-700 text-slate-400 hover:border-slate-600']">
            <input type="radio" v-model="form.priority" :value="p.value" class="hidden" />
            {{ p.label }}
          </label>
        </div>
      </div>

      <!-- Slot calendar -->
      <div>
        <label class="block text-sm text-slate-400 mb-3">Horario preferido *</label>
        <SlotCalendar v-model="selectedSlot" />
      </div>

      <!-- Error -->
      <p v-if="error" class="text-red-400 text-sm text-center">{{ error }}</p>

      <!-- Submit -->
      <button type="submit" class="btn-primary w-full justify-center" :disabled="loading || !isValid">
        {{ loading ? 'Enviando...' : '📨 Enviar solicitud' }}
      </button>
    </form>
  </BaseModal>
</template>
