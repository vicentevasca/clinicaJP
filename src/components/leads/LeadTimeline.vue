<script setup>
import { LEAD_STATUS_LABELS } from '@/utils/constants'
defineProps({
  history: { type: Array, default: () => [] }
})
</script>
<template>
  <div class="space-y-0">
    <div v-for="(entry, i) in history" :key="entry.id"
      class="flex gap-3 pb-4 relative"
      :class="i < history.length - 1 ? 'border-l border-slate-700 ml-2 pl-5' : 'ml-2 pl-5'">
      <!-- Línea vertical -->
      <div v-if="i < history.length - 1" class="absolute left-[7px] top-6 bottom-0 w-px bg-slate-700" />
      <!-- Punto -->
      <div class="w-3 h-3 rounded-full bg-brand-500 flex-shrink-0 mt-1 -ml-5" />
      <div>
        <p class="text-sm text-slate-300">
          <span class="font-medium">{{ LEAD_STATUS_LABELS[entry.to_status] || entry.to_status }}</span>
        </p>
        <p v-if="entry.note" class="text-xs text-slate-500 mt-0.5">{{ entry.note }}</p>
        <p class="text-xs text-slate-600 mt-0.5">
          {{ new Date(entry.created_at).toLocaleString('es-CL') }}
        </p>
      </div>
    </div>
    <p v-if="!history.length" class="text-center py-4 text-slate-500 text-sm">Sin historial</p>
  </div>
</template>
