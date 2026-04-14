<script setup>
import { computed } from 'vue'

const props = defineProps({
  item: { type: Object, required: true }
})
defineEmits(['click'])

const stockPercent = computed(() => {
  if (!props.item.min_stock) return 100
  return Math.min(100, Math.round((props.item.stock / props.item.min_stock) * 100))
})

const stockColor = computed(() => {
  if (props.item.stock <= props.item.min_stock) return 'bg-red-500'
  if (stockPercent.value < 150) return 'bg-amber-500'
  return 'bg-brand-500'
})
</script>

<template>
  <div class="card p-4 cursor-pointer hover:border-brand-500/40 transition-all animate-in"
    @click="$emit('click', item)">
    <div class="flex items-start justify-between mb-2">
      <div>
        <p class="font-medium text-white">{{ item.name }}</p>
        <p class="text-xs text-slate-500 capitalize">{{ item.category }}</p>
      </div>
      <span class="badge bg-slate-700/60 text-slate-400 text-xs">{{ item.unit }}</span>
    </div>
    <!-- Barra de stock -->
    <div class="mb-1">
      <div class="flex justify-between text-xs mb-0.5">
        <span class="text-slate-500">Stock</span>
        <span :class="item.stock <= item.min_stock ? 'text-red-400' : 'text-slate-400'">
          {{ item.stock }} / {{ item.min_stock }}
        </span>
      </div>
      <div class="h-1.5 bg-slate-700 rounded-full overflow-hidden">
        <div class="h-full rounded-full transition-all duration-500" :class="stockColor"
          :style="{ width: stockPercent + '%' }" />
      </div>
    </div>
    <p v-if="item.stock <= item.min_stock" class="text-xs text-red-400 font-medium">
      ⚠️ Bajo stock mínimo
    </p>
    <p v-if="item.supplier_name" class="text-xs text-slate-600 mt-1">Proveedor: {{ item.supplier_name }}</p>
  </div>
</template>
