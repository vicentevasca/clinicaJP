<script setup>
import { RouterLink } from 'vue-router'
const actions = [
  { to: '/app/leads',        icon: '📋', label: 'Nuevo lead',   color: 'bg-brand-600 hover:bg-brand-500' },
  { to: '/app/agenda',       icon: '📅', label: 'Ver agenda',   color: 'bg-blue-600 hover:bg-blue-500' },
  { to: '/app/inventario',   icon: '📦', label: 'Revisar stock', color: 'bg-amber-600 hover:bg-amber-500' },
  { to: '/app/leads',               icon: '💬', label: 'Leads en espera', color: 'bg-slate-600 hover:bg-slate-500' },
]
</script>
<template>
  <div class="flex flex-wrap gap-3">
    <RouterLink
      v-for="a in actions" :key="a.to"
      :to="a.to"
      class="inline-flex items-center gap-2 px-4 py-2.5 rounded-lg text-white text-sm font-medium transition-colors"
      :class="a.color"
    >
      <span>{{ a.icon }}</span>
      <span>{{ a.label }}</span>
    </RouterLink>
  </div>
</template>
