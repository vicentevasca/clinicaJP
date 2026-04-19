<script setup>
defineProps({
  label:   { type: String, required: true },
  value:   { type: [String, Number], required: true },
  icon:    { type: String, default: '' },
  trend:   { type: String, default: null },   // 'up' | 'down' | null
  loading: { type: Boolean, default: false },
})
</script>
<template>
  <div class="card p-5 animate-in">
    <div class="flex items-start justify-between">
      <div>
        <p class="text-xs font-medium uppercase tracking-wide mb-1" style="color: var(--text-muted);">{{ label }}</p>
        <p class="text-2xl font-bold" style="color: var(--text-primary);">
          <span v-if="loading" style="color: var(--text-muted); opacity: 0.4;">—</span>
          <span v-else>{{ value }}</span>
        </p>
      </div>
      <div v-if="icon" class="text-2xl">{{ icon }}</div>
    </div>
    <div v-if="trend" class="mt-2 flex items-center gap-1 text-xs font-medium"
      :class="trend === 'up' ? 'text-brand-400' : 'text-red-400'">
      <span>{{ trend === 'up' ? '↑' : '↓' }}</span>
      <span>vs ayer</span>
    </div>
  </div>
</template>
