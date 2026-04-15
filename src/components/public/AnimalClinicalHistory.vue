<script setup>
import { computed } from 'vue'

const props = defineProps({
  animal: { type: Object, required: true },
})

const records = computed(() => {
  return [...(props.animal.clinical_records || [])].sort((a, b) =>
    new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
  )
})

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleDateString('es-CL', {
    day: '2-digit', month: 'short', year: 'numeric',
  })
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-white">
        📋 Historial clínico de <span class="text-brand-400">{{ animal.name }}</span>
      </h3>
    </div>

    <!-- Empty state -->
    <div v-if="records.length === 0" class="card p-8 text-center">
      <span class="text-4xl mb-3 block">📭</span>
      <p class="text-slate-400">Este animal aún no tiene registros clínicos</p>
      <p class="text-xs text-slate-600 mt-1">Los registros se crean al cerrar una visita</p>
    </div>

    <!-- Timeline -->
    <div v-else class="relative">
      <div class="absolute left-5 top-0 bottom-0 w-px bg-slate-700" />

      <div
        v-for="(record, i) in records"
        :key="record.id"
        class="relative pl-10 pb-6 last:pb-0"
      >
        <!-- Dot -->
        <div class="absolute left-3.5 w-3 h-3 rounded-full bg-brand-500 border-2 border-slate-900 mt-1.5" />

        <!-- Card -->
        <div class="card p-4">
          <div class="flex items-center justify-between mb-2">
            <span class="text-xs font-medium text-brand-400">
              {{ formatDate(record.created_at) }}
            </span>
            <span v-if="record.visit" class="text-xs text-slate-500">
              {{ record.visit.status === 'completed' ? '✅ Completada' : '📅 Programada' }}
            </span>
          </div>

          <!-- Vitals -->
          <div v-if="record.weight_kg || record.temperature_c" class="flex gap-4 mb-3">
            <div v-if="record.weight_kg" class="text-xs">
              <span class="text-slate-500">Peso:</span>
              <span class="text-white ml-1">{{ record.weight_kg }} kg</span>
            </div>
            <div v-if="record.temperature_c" class="text-xs">
              <span class="text-slate-500">Temp:</span>
              <span class="text-white ml-1">{{ record.temperature_c }} °C</span>
            </div>
          </div>

          <!-- Content -->
          <div v-if="record.diagnosis" class="mb-2">
            <span class="text-xs text-slate-500 block mb-0.5">Diagnóstico</span>
            <p class="text-sm text-white">{{ record.diagnosis }}</p>
          </div>

          <div v-if="record.treatment" class="mb-2">
            <span class="text-xs text-slate-500 block mb-0.5">Tratamiento</span>
            <p class="text-sm text-white">{{ record.treatment }}</p>
          </div>

          <div v-if="record.prescriptions" class="mb-2">
            <span class="text-xs text-slate-500 block mb-0.5">Recetas</span>
            <p class="text-sm text-white">{{ record.prescriptions }}</p>
          </div>

          <div v-if="record.observations">
            <span class="text-xs text-slate-500 block mb-0.5">Observaciones</span>
            <p class="text-sm text-slate-300">{{ record.observations }}</p>
          </div>

          <div v-if="record.next_visit_rec" class="mt-3 pt-3 border-t border-slate-700">
            <span class="text-xs text-slate-500 block mb-0.5">Próxima visita recomendada</span>
            <p class="text-sm text-brand-400">{{ record.next_visit_rec }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
