<script setup>
defineProps({
  visit: { type: Object, required: true }
})
defineEmits(['click'])

const statusColor = {
  scheduled:  'bg-blue-500/20 text-blue-400',
  confirmed:  'bg-teal-500/20 text-teal-400',
  in_progress:'bg-amber-500/20 text-amber-400',
  completed:  'bg-brand-500/20 text-brand-400',
  cancelled:  'bg-slate-500/20 text-slate-400',
}
</script>
<template>
  <div
    class="card p-3 cursor-pointer hover:border-brand-500/40 transition-all"
    :class="statusColor[visit.status]"
    @click="$emit('click', visit)"
  >
    <div class="flex items-center justify-between mb-1">
      <span class="text-xs font-medium">{{ visit.animal?.name || '—' }}</span>
      <span class="badge text-xs" :class="statusColor[visit.status]">{{ visit.status }}</span>
    </div>
    <p class="text-xs text-slate-400 truncate">{{ new Date(visit.scheduled_at).toLocaleString('es-CL') }}</p>
    <p class="text-xs text-slate-500 truncate">{{ visit.address }}</p>
  </div>
</template>
