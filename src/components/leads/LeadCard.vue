<script setup>
import { LEAD_STATUS_COLORS, SERVICE_TYPES, PRIORITY_LEVELS } from '@/utils/constants'

defineProps({
  lead: { type: Object, required: true }
})
defineEmits(['click'])

const speciesEmoji = {
  perro: '🐕', gato: '🐈', ave: '🐦', gallina: '🐔', caballo: '🐴', bovino: '🐄', otro: '🐾'
}
const priorityColor = {
  low: 'text-slate-400', normal: 'text-blue-400', high: 'text-amber-400', urgent: 'text-red-400'
}
const priorityEmoji = { low: '⚪', normal: '🔵', high: '🟡', urgent: '🔴' }

const serviceLabel = (val) => SERVICE_TYPES.find(s => s.value === val)?.label ?? val
const priorityLabel = (val) => PRIORITY_LEVELS.find(p => p.value === val)?.label ?? val
</script>
<template>
  <div
    class="card p-3 cursor-pointer hover:border-brand-500/40 transition-all hover:scale-[1.01] animate-in"
    @click="$emit('click')"
  >
    <div class="flex items-start gap-3">
      <span class="text-lg flex-shrink-0">{{ speciesEmoji[lead.animal?.species] || '🐾' }}</span>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-medium text-slate-200 truncate">{{ lead.client?.name || 'Sin nombre' }}</p>
        <p class="text-xs text-slate-500 truncate">{{ lead.animal?.name }} · {{ serviceLabel(lead.service_type) }}</p>
        <div class="flex items-center gap-2 mt-1.5">
          <span class="text-xs" :class="priorityColor[lead.priority]">
            {{ priorityEmoji[lead.priority] || '⚪' }} {{ priorityLabel(lead.priority) }}
          </span>
          <span class="text-xs text-slate-600">·</span>
          <span class="text-xs text-slate-500">{{ new Date(lead.created_at).toLocaleDateString('es-CL') }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
