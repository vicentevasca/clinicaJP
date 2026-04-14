<script setup>
defineProps({
  procedure: { type: Object, required: true }
})
defineEmits(['click', 'edit'])

const categoryColor = {
  vaccinacion:        'bg-blue-500/20 text-blue-400',
  desparasitacion:    'bg-purple-500/20 text-purple-400',
  chequeo:            'bg-teal-500/20 text-teal-400',
  receta:             'bg-amber-500/20 text-amber-400',
  corte_pelo:         'bg-pink-500/20 text-pink-400',
  atencion_domicilio: 'bg-brand-500/20 text-brand-400',
  otro:               'bg-slate-500/20 text-slate-400',
}
</script>
<template>
  <div class="card p-4 hover:border-brand-500/40 transition-all animate-in cursor-pointer"
    @click="$emit('click', procedure)">
    <div class="flex items-start justify-between mb-2">
      <div>
        <p class="font-medium text-white">{{ procedure.name }}</p>
        <p class="text-xs text-slate-500 capitalize">{{ procedure.category?.replace('_', ' ') }}</p>
      </div>
      <span class="badge text-xs" :class="categoryColor[procedure.category] || categoryColor.otro">
        {{ procedure.category }}
      </span>
    </div>
    <p v-if="procedure.description" class="text-xs text-slate-400 mb-2 line-clamp-2">
      {{ procedure.description }}
    </p>
    <div class="flex items-center gap-3 text-xs text-slate-500">
      <span v-if="procedure.duration_min">⏱ {{ procedure.duration_min }} min</span>
      <span v-if="procedure.base_price">💰 ${{ procedure.base_price.toLocaleString('es-CL') }}</span>
    </div>
    <!-- Insumos requeridos -->
    <div v-if="procedure.procedure_inventory?.length" class="mt-2 flex flex-wrap gap-1">
      <span v-for="pi in procedure.procedure_inventory" :key="pi.id"
        class="badge bg-slate-700/60 text-slate-400 text-xs">
        {{ pi.inventory?.name }} {{ pi.quantity ? `×${pi.quantity}` : '' }}
      </span>
    </div>
  </div>
</template>
