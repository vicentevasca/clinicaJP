<script setup>
import { ref, watch } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { clinicalService } from '@/services/clinical.service'
import { patientsService } from '@/services/patients.service'
import { useToast } from '@/composables/useToast'

const props = defineProps({
  visitId:  { type: String, required: true },
  animalId: { type: String, default: null },
  existing: { type: Object, default: null },
})
const emit = defineEmits(['saved'])

const authStore = useAuthStore()
const { addToast } = useToast()

const form = ref({
  weight_kg:       '',
  temperature_c:   '',
  diagnosis:       '',
  treatment:       '',
  prescriptions:   '',
  observations:    '',
  next_visit_rec:  '',
})
const saving = ref(false)

watch(() => props.existing, (v) => {
  if (v) {
    form.value = {
      weight_kg:       v.weight_kg || '',
      temperature_c:   v.temperature_c || '',
      diagnosis:       v.diagnosis || '',
      treatment:       v.treatment || '',
      prescriptions:   v.prescriptions || '',
      observations:    v.observations || '',
      next_visit_rec: v.next_visit_rec || '',
    }
  }
}, { immediate: true })

async function save() {
  saving.value = true
  try {
    const payload = {
      visit_id:        props.visitId,
      animal_id:       props.existing?.animal_id ?? props.animalId,
      diagnosis:       form.value.diagnosis,
      treatment:       form.value.treatment,
      prescriptions:   form.value.prescriptions,
      observations:    form.value.observations,
      next_visit_rec:  form.value.next_visit_rec,
      created_by:      authStore.profile?.id || null,
    }
    if (form.value.weight_kg)     payload.weight_kg     = parseFloat(form.value.weight_kg)
    if (form.value.temperature_c)  payload.temperature_c = parseFloat(form.value.temperature_c)

    if (props.existing?.id) {
      await clinicalService.update(props.existing.id, payload)
    } else {
      await clinicalService.create(payload)
    }

    // Actualizar peso del animal con el registro más reciente
    const animalId = props.existing?.animal_id ?? props.animalId
    if (payload.weight_kg && animalId) {
      await patientsService.updateWeight(animalId, payload.weight_kg)
    }

    addToast('Ficha guardada', 'success')
    emit('saved')
  } catch (e) {
    addToast('Error: ' + e.message, 'error')
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="card p-4">
    <h3 class="text-sm font-semibold text-slate-300 mb-3">📋 Cerrar Visita</h3>
    <form @submit.prevent="save" class="space-y-3">
      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="label-base">Peso (kg)</label>
          <input v-model="form.weight_kg" type="number" step="0.1" class="input-base" placeholder="Ej: 12.5" />
        </div>
        <div>
          <label class="label-base">Temperatura (°C)</label>
          <input v-model="form.temperature_c" type="number" step="0.1" class="input-base" placeholder="Ej: 38.5" />
        </div>
        <div class="col-span-2">
          <label class="label-base">Diagnóstico *</label>
          <input v-model="form.diagnosis" type="text" class="input-base" required />
        </div>
        <div class="col-span-2">
          <label class="label-base">Tratamiento *</label>
          <input v-model="form.treatment" type="text" class="input-base" required />
        </div>
        <div class="col-span-2">
          <label class="label-base">Recetas</label>
          <input v-model="form.prescriptions" type="text" class="input-base" />
        </div>
        <div class="col-span-2">
          <label class="label-base">Observaciones</label>
          <textarea v-model="form.observations" class="input-base" rows="2" />
        </div>
        <div class="col-span-2">
          <label class="label-base">Próxima visita recomendada</label>
          <input v-model="form.next_visit_rec" type="text" class="input-base" placeholder="Ej: 6 meses" />
        </div>
      </div>
      <button type="submit" class="btn-primary w-full" :disabled="saving">
        {{ saving ? 'Guardando...' : 'Guardar ficha clínica' }}
      </button>
    </form>
  </div>
</template>
