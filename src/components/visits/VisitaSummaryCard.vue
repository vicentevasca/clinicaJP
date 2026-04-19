<script setup>
import { RouterLink } from 'vue-router'
import { VISIT_STATUS_LABELS } from '@/utils/constants'

defineProps({
  visit: { type: Object, default: null }
})

const statusColor = {
  scheduled:  'bg-blue-500/20 text-blue-400 border-blue-500/30',
  confirmed:  'bg-teal-500/20 text-teal-400 border-teal-500/30',
  in_progress:'bg-amber-500/20 text-amber-400 border-amber-500/30',
  completed:  'bg-brand-500/20 text-brand-400 border-brand-500/30',
  cancelled:  'bg-slate-500/20 text-slate-400 border-slate-500/30',
}
</script>
<template>
  <div v-if="visit" class="card p-4">
    <div class="flex items-center justify-between mb-2">
      <h4 class="text-sm font-semibold text-slate-300">Visita programada</h4>
      <span class="badge" :class="statusColor[visit.status]">{{ VISIT_STATUS_LABELS[visit.status] || visit.status }}</span>
    </div>
    <p class="text-sm text-slate-400">
      📅 {{ new Date(visit.scheduled_at).toLocaleString('es-CL') }}
    </p>
    <p class="text-sm text-slate-400">📍 {{ visit.address }}</p>
    <RouterLink :to="`/app/visitas/${visit.id}`" class="btn-ghost text-xs mt-2 inline-block">
      Ver detalle →
    </RouterLink>
  </div>
  <div v-else class="card p-4 text-center text-slate-500 text-sm">
    Sin visita asociada
  </div>
</template>
