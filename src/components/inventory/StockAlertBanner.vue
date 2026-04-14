<script setup>
defineProps({
  count: { type: Number, default: 0 }
})
</script>
<template>
  <div v-if="count > 0"
    class="flex items-center gap-3 p-3 rounded-lg bg-red-500/15 border border-red-500/30 text-sm">
    <span class="text-red-400 text-lg">⚠️</span>
    <p class="text-red-300 font-medium">
      {{ count }} insumo{{ count > 1 ? 's' : '' }} bajo stock mínimo
    </p>
    <RouterLink to="/app/inventario?filter=critical"
      class="ml-auto btn-ghost text-xs text-red-400 hover:text-red-300">
      Revisar →
    </RouterLink>
  </div>
</template>
