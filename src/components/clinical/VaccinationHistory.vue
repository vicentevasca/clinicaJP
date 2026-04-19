<script setup>
import { ref, onMounted } from 'vue'
import { vaccinationsService } from '@/services/vaccinations.service'
import { useToast } from '@/composables/useToast'

const props = defineProps({
  animalId: { type: String, required: true },
})

const { addToast } = useToast()
const vaccinations = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    vaccinations.value = await vaccinationsService.getByAnimalId(props.animalId)
  } catch (e) {
    addToast('Error al cargar vacunas: ' + e.message, 'error')
  } finally {
    loading.value = false
  }
})

function isOverdue(nextDueDate) {
  if (!nextDueDate) return false
  return new Date(nextDueDate) < new Date()
}

function isDueSoon(nextDueDate) {
  if (!nextDueDate) return false
  const diff = new Date(nextDueDate) - new Date()
  return diff > 0 && diff < 30 * 24 * 60 * 60 * 1000
}

function formatDate(d) {
  if (!d) return '—'
  return new Date(d + 'T12:00:00').toLocaleDateString('es-CL')
}
</script>

<template>
  <div>
    <div v-if="loading" class="text-center py-4 text-slate-500 text-sm">Cargando...</div>

    <div v-else-if="!vaccinations.length"
      class="text-center py-6 text-slate-500 text-sm">
      Sin vacunas registradas
    </div>

    <div v-else class="space-y-3">
      <!-- Alertas de próximas dosis -->
      <div v-if="vaccinations.some(v => isOverdue(v.next_due_date))"
        class="bg-red-500/10 border border-red-500/30 rounded-lg px-3 py-2 text-xs text-red-400">
        ⚠️ Hay vacunas con refuerzo vencido
      </div>
      <div v-else-if="vaccinations.some(v => isDueSoon(v.next_due_date))"
        class="bg-amber-500/10 border border-amber-500/30 rounded-lg px-3 py-2 text-xs text-amber-400">
        📅 Hay refuerzos pendientes en menos de 30 días
      </div>

      <!-- Lista -->
      <div v-for="vac in vaccinations" :key="vac.id"
        class="border-l-2 pl-3 py-1 relative"
        :class="{
          'border-red-500':   isOverdue(vac.next_due_date),
          'border-amber-400': isDueSoon(vac.next_due_date) && !isOverdue(vac.next_due_date),
          'border-brand-500': !vac.next_due_date || (!isOverdue(vac.next_due_date) && !isDueSoon(vac.next_due_date)),
        }">
        <div class="flex items-start justify-between mb-1">
          <p class="text-sm font-medium text-slate-300">{{ vac.vaccine_name }}</p>
          <span class="text-xs text-slate-500 ml-2 shrink-0">
            {{ formatDate(vac.administered_at) }}
          </span>
        </div>

        <div class="flex flex-wrap gap-x-3 gap-y-0.5 text-xs text-slate-500">
          <span v-if="vac.lab_name">{{ vac.lab_name }}</span>
          <span v-if="vac.batch_number">Lote: {{ vac.batch_number }}</span>
          <span v-if="vac.dose_number">Dosis {{ vac.dose_number }}</span>
        </div>

        <div v-if="vac.next_due_date" class="mt-1 text-xs"
          :class="{
            'text-red-400':   isOverdue(vac.next_due_date),
            'text-amber-400': isDueSoon(vac.next_due_date) && !isOverdue(vac.next_due_date),
            'text-slate-500': !isOverdue(vac.next_due_date) && !isDueSoon(vac.next_due_date),
          }">
          Refuerzo: {{ formatDate(vac.next_due_date) }}
          <span v-if="isOverdue(vac.next_due_date)"> · VENCIDO</span>
          <span v-else-if="isDueSoon(vac.next_due_date)"> · Próximo</span>
        </div>

        <p v-if="vac.notes" class="text-xs text-slate-500 mt-1 italic">{{ vac.notes }}</p>
      </div>
    </div>
  </div>
</template>
