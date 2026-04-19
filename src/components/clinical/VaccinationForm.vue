<script setup>
import { ref, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { vaccinationsService } from '@/services/vaccinations.service'
import { useToast } from '@/composables/useToast'

const props = defineProps({
  visitId:  { type: String, required: true },
  animalId: { type: String, required: true },
})
const emit = defineEmits(['saved'])

const authStore = useAuthStore()
const { addToast } = useToast()

const VACCINES_PRESET = [
  'Quíntuple canina (DA2PPL)',
  'Séxtuple canina (DA2PPLv)',
  'Antirrábica',
  'Bordetella',
  'Triple felina (FHV-FCV-FPV)',
  'Leucemia felina (FeLV)',
  'Rabia felina',
  'Influenza equina',
  'Tétanos equino',
  'Clostridiosis bovina',
  'Otra (especificar)',
]

const vaccinations = ref([createEmpty()])
const saving = ref(false)

function createEmpty() {
  return {
    vaccine_name:    '',
    custom_name:     '',
    batch_number:    '',
    lab_name:        '',
    dose_number:     1,
    administered_at: new Date().toISOString().slice(0, 10),
    next_due_date:   '',
    notes:           '',
  }
}

function addVaccine() {
  vaccinations.value.push(createEmpty())
}

function removeVaccine(i) {
  vaccinations.value.splice(i, 1)
}

const hasValidVaccines = computed(() =>
  vaccinations.value.some(v => v.vaccine_name && v.vaccine_name !== '')
)

function resolveName(v) {
  return v.vaccine_name === 'Otra (especificar)' ? v.custom_name : v.vaccine_name
}

async function save() {
  const toSave = vaccinations.value.filter(v => v.vaccine_name && v.vaccine_name !== '')
  if (!toSave.length) {
    addToast('Agregá al menos una vacuna', 'warning')
    return
  }
  saving.value = true
  try {
    for (const v of toSave) {
      const payload = {
        animal_id:       props.animalId,
        visit_id:        props.visitId,
        vaccine_name:    resolveName(v),
        batch_number:    v.batch_number || null,
        lab_name:        v.lab_name || null,
        dose_number:     v.dose_number || 1,
        administered_at: v.administered_at,
        next_due_date:   v.next_due_date || null,
        notes:           v.notes || null,
        created_by:      authStore.profile?.id || null,
      }
      await vaccinationsService.create(payload)
    }
    addToast(`${toSave.length} vacuna${toSave.length > 1 ? 's' : ''} registrada${toSave.length > 1 ? 's' : ''}`, 'success')
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
    <div class="flex items-center justify-between mb-3">
      <h3 class="text-sm font-semibold text-slate-300">💉 Vacunas aplicadas</h3>
      <button type="button" @click="addVaccine"
        class="text-xs text-brand-400 hover:text-brand-300 transition-colors">
        + Agregar vacuna
      </button>
    </div>

    <div class="space-y-4">
      <div v-for="(v, i) in vaccinations" :key="i"
        class="border border-slate-700 rounded-lg p-3 space-y-3 relative">

        <button v-if="vaccinations.length > 1"
          type="button" @click="removeVaccine(i)"
          class="absolute top-2 right-2 text-slate-600 hover:text-red-400 text-xs transition-colors">
          ✕
        </button>

        <!-- Vacuna -->
        <div>
          <label class="label-base">Vacuna *</label>
          <select v-model="v.vaccine_name" class="input-base">
            <option value="">Seleccionar...</option>
            <option v-for="preset in VACCINES_PRESET" :key="preset" :value="preset">
              {{ preset }}
            </option>
          </select>
        </div>

        <!-- Nombre personalizado si es "Otra" -->
        <div v-if="v.vaccine_name === 'Otra (especificar)'">
          <label class="label-base">Nombre de la vacuna *</label>
          <input v-model="v.custom_name" type="text" class="input-base"
            placeholder="Ej: Vacuna Newcastle..." />
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="label-base">N° de lote</label>
            <input v-model="v.batch_number" type="text" class="input-base"
              placeholder="Ej: L2024-003" />
          </div>
          <div>
            <label class="label-base">Laboratorio</label>
            <input v-model="v.lab_name" type="text" class="input-base"
              placeholder="Ej: Zoetis" />
          </div>
          <div>
            <label class="label-base">Dosis N°</label>
            <input v-model.number="v.dose_number" type="number" min="1" max="10"
              class="input-base" />
          </div>
          <div>
            <label class="label-base">Fecha aplicación</label>
            <input v-model="v.administered_at" type="date" class="input-base" />
          </div>
          <div class="col-span-2">
            <label class="label-base">Próxima dosis (opcional)</label>
            <input v-model="v.next_due_date" type="date" class="input-base" />
          </div>
          <div class="col-span-2">
            <label class="label-base">Notas</label>
            <input v-model="v.notes" type="text" class="input-base"
              placeholder="Reacciones, observaciones..." />
          </div>
        </div>
      </div>
    </div>

    <button type="button" @click="save"
      class="btn-primary w-full mt-4"
      :disabled="saving || !hasValidVaccines">
      {{ saving ? 'Guardando...' : 'Guardar vacunas' }}
    </button>
  </div>
</template>
