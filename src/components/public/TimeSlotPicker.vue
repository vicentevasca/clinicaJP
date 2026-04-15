<script setup>
const props = defineProps({
  slot: { type: Object, required: true },
  selected: { type: Boolean, default: false },
})

const emit = defineEmits(['select'])

const labels = {
  maniana: 'Mañana',
  tarde: 'Tarde',
  noche: 'Noche',
}
</script>

<template>
  <button
    type="button"
    @click="slot.available && emit('select', slot)"
    :disabled="!slot.available"
    :class="[
      'flex flex-col items-center justify-center px-3 py-2 rounded-lg text-xs font-medium transition-all',
      slot.available
        ? selected
          ? 'bg-brand-500 text-white ring-2 ring-brand-400'
          : 'bg-slate-700 text-slate-200 hover:bg-brand-600 hover:text-white'
        : 'bg-slate-800 text-slate-600 line-through cursor-not-allowed opacity-50',
    ]"
  >
    <span class="text-lg mb-0.5">
      {{ { maniana: '🌅', tarde: '☀️', noche: '🌙' }[slot.time_slot] }}
    </span>
    <span>{{ labels[slot.time_slot] }}</span>
    <span v-if="!slot.available" class="text-[10px] mt-0.5 opacity-70">Ocupado</span>
  </button>
</template>
