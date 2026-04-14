<script setup>
import { RouterLink } from 'vue-router'
import { LEAD_STATUS_COLORS, LEAD_STATUS_LABELS } from '@/utils/constants'

defineProps({
  leads: { type: Array, default: () => [] },
})
</script>
<template>
  <div class="space-y-2">
    <RouterLink
      v-for="lead in leads" :key="lead.id"
      :to="`/app/leads/${lead.id}`"
      class="flex items-center justify-between p-3 rounded-lg bg-slate-800/40 hover:bg-slate-800/70 border border-slate-700/40 transition-colors"
    >
      <div class="flex items-center gap-3 min-w-0">
        <span class="text-lg">
          {{ { perro:'🐕', gato:'🐈', ave:'🐦', gallina:'🐔', caballo:'🐴', bovino:'🐄', otro:'🐾' }[lead.animal?.species] || '🐾' }}
        </span>
        <div class="min-w-0">
          <p class="text-sm font-medium text-slate-200 truncate">{{ lead.client?.name || 'Sin nombre' }}</p>
          <p class="text-xs text-slate-500 truncate">{{ lead.animal?.name }} · {{ lead.service_type }}</p>
        </div>
      </div>
      <span class="badge flex-shrink-0" :class="LEAD_STATUS_COLORS[lead.status]">
        {{ LEAD_STATUS_LABELS[lead.status] }}
      </span>
    </RouterLink>
    <p v-if="!leads.length" class="text-center py-4 text-slate-500 text-sm">Sin leads recientes</p>
  </div>
</template>
