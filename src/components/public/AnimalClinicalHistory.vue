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
      <h3 class="text-lg font-semibold" style="color: var(--text-primary);">
        📋 Historial clínico de <span style="color: var(--btn-primary-bg);">{{ animal.name }}</span>
      </h3>
    </div>

    <!-- Empty state -->
    <div v-if="records.length === 0" class="card p-8 text-center">
      <span class="text-4xl mb-3 block">📭</span>
      <p style="color: var(--text-muted);">Este animal aún no tiene registros clínicos</p>
      <p class="text-xs mt-1" style="color: var(--text-muted); opacity: 0.7;">Los registros se crean al cerrar una visita</p>
    </div>

    <!-- Timeline -->
    <div v-else class="relative">
      <div class="absolute left-5 top-0 bottom-0 w-px" style="background-color: var(--border-color);" />

      <div
        v-for="(record, i) in records"
        :key="record.id"
        class="relative pl-10 pb-6 last:pb-0"
      >
        <!-- Dot -->
        <div class="absolute left-3.5 w-3 h-3 rounded-full bg-brand-500 border-2 mt-1.5"
          style="border-color: var(--bg-primary);" />

        <!-- Card -->
        <div class="card p-4">
          <div class="flex items-center justify-between mb-2">
            <span class="text-xs font-medium" style="color: var(--btn-primary-bg);">
              {{ formatDate(record.created_at) }}
            </span>
            <span v-if="record.visit" class="text-xs" style="color: var(--text-muted);">
              {{ record.visit.status === 'completed' ? '✅ Completada' : '📅 Programada' }}
            </span>
          </div>

          <!-- Vitals -->
          <div v-if="record.weight_kg || record.temperature_c" class="flex gap-4 mb-3">
            <div v-if="record.weight_kg" class="text-xs">
              <span style="color: var(--text-muted);">Peso:</span>
              <span class="ml-1 font-medium" style="color: var(--text-primary);">{{ record.weight_kg }} kg</span>
            </div>
            <div v-if="record.temperature_c" class="text-xs">
              <span style="color: var(--text-muted);">Temp:</span>
              <span class="ml-1 font-medium" style="color: var(--text-primary);">{{ record.temperature_c }} °C</span>
            </div>
          </div>

          <!-- Content -->
          <div v-if="record.diagnosis" class="mb-2">
            <span class="text-xs block mb-0.5" style="color: var(--text-muted);">Diagnóstico</span>
            <p class="text-sm" style="color: var(--text-primary);">{{ record.diagnosis }}</p>
          </div>

          <div v-if="record.treatment" class="mb-2">
            <span class="text-xs block mb-0.5" style="color: var(--text-muted);">Tratamiento</span>
            <p class="text-sm" style="color: var(--text-primary);">{{ record.treatment }}</p>
          </div>

          <div v-if="record.prescriptions" class="mb-2">
            <span class="text-xs block mb-0.5" style="color: var(--text-muted);">Recetas</span>
            <p class="text-sm" style="color: var(--text-primary);">{{ record.prescriptions }}</p>
          </div>

          <div v-if="record.observations">
            <span class="text-xs block mb-0.5" style="color: var(--text-muted);">Observaciones</span>
            <p class="text-sm" style="color: var(--text-secondary);">{{ record.observations }}</p>
          </div>

          <div v-if="record.next_visit_rec" class="mt-3 pt-3" style="border-top: 1px solid var(--border-color);">
            <span class="text-xs block mb-0.5" style="color: var(--text-muted);">Próxima visita recomendada</span>
            <p class="text-sm" style="color: var(--btn-primary-bg);">{{ record.next_visit_rec }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
