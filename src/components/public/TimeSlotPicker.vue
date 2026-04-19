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
    class="flex flex-col items-center justify-center px-3 py-2 rounded-lg text-xs font-medium transition-all"
    :style="slot.available
      ? selected
        ? 'background-color: var(--btn-primary-bg); color: white; outline: 2px solid var(--btn-primary-bg); outline-offset: 1px;'
        : 'background-color: var(--bg-secondary); color: var(--text-primary); border: 1px solid var(--border-color);'
      : 'background-color: var(--bg-secondary); color: var(--text-muted); opacity: 0.5; cursor: not-allowed; text-decoration: line-through;'"
  >
    <span class="text-lg mb-0.5">
      {{ { maniana: '🌅', tarde: '☀️', noche: '🌙' }[slot.time_slot] }}
    </span>
    <span>{{ labels[slot.time_slot] }}</span>
    <span v-if="!slot.available" class="text-[10px] mt-0.5 opacity-70">Ocupado</span>
  </button>
</template>
