<script setup>
import LeadCard from './LeadCard.vue'

defineProps({
  title:     { type: String, required: true },
  leads:     { type: Array, default: () => [] },
  accentColor: { type: String, default: 'border-slate-600' },
})
defineEmits(['lead-click', 'new-lead'])
</script>
<template>
  <div class="flex flex-col h-full">
    <div class="flex items-center justify-between mb-3 px-1">
      <div class="flex items-center gap-2">
        <span class="w-2 h-2 rounded-full" :class="accentColor.replace('border-', 'bg-')" />
        <h3 class="text-sm font-semibold text-slate-300">{{ title }}</h3>
        <span class="badge bg-slate-700/60 text-slate-400">{{ leads.length }}</span>
      </div>
    </div>
    <div class="flex-1 overflow-y-auto space-y-2 pr-0.5" style="max-height: calc(100vh - 220px);">
      <LeadCard
        v-for="lead in leads" :key="lead.id"
        :lead="lead"
        @click="$emit('lead-click', lead)"
      />
      <p v-if="!leads.length" class="text-center py-6 text-slate-600 text-xs">Sin leads</p>
    </div>
  </div>
</template>
