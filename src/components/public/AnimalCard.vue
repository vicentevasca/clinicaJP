<script setup>
import { computed } from 'vue'

const props = defineProps({
  animal: { type: Object, required: true },
  selected: { type: Boolean, default: false },
})

const emit = defineEmits(['view-history', 'new-consultation'])

const speciesEmoji = {
  perro: '🐕',
  gato: '🐈',
  ave: '🐦',
  gallina: '🐔',
  caballo: '🐴',
  bovino: '🐄',
  otro: '🐾',
}

const lastRecord = computed(() => {
  const records = props.animal.clinical_records || []
  return records[0] || null
})

const recordCount = computed(() => (props.animal.clinical_records || []).length)
</script>

<template>
  <div
    :class="['card p-5 transition-all hover:-translate-y-0.5 cursor-pointer border-2',
      selected ? 'border-brand-500' : 'border-transparent hover:border-slate-600']"
    @click="emit('view-history', animal)"
  >
    <div class="flex items-start gap-4">
      <!-- Avatar -->
      <div class="w-16 h-16 rounded-xl bg-brand-600/20 flex items-center justify-center text-3xl flex-shrink-0">
        {{ speciesEmoji[animal.species] || '🐾' }}
      </div>

      <!-- Info -->
      <div class="flex-1 min-w-0">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-white truncate">{{ animal.name }}</h3>
          <span class="text-xs px-2 py-0.5 rounded-full bg-slate-700 text-slate-300 capitalize">
            {{ animal.sex || '?' }}
          </span>
        </div>
        <p class="text-sm text-slate-400 capitalize">
          {{ animal.species }} {{ animal.breed ? `· ${animal.breed}` : '' }}
        </p>
        <p v-if="animal.birth_date" class="text-xs text-slate-500 mt-0.5">
          {{ new Date().getFullYear() - new Date(animal.birth_date).getFullYear() }} años aprox.
        </p>

        <!-- Last record -->
        <div v-if="lastRecord" class="mt-2 text-xs text-slate-500 line-clamp-1">
          📋 Último registro: {{ lastRecord.diagnosis || 'Sin diagnóstico' }}
        </div>
        <div v-else class="mt-2 text-xs text-slate-600">
          Sin registros clínicos aún
        </div>
      </div>
    </div>

    <!-- Actions -->
    <div class="mt-4 flex gap-2" @click.stop>
      <button
        type="button"
        @click="emit('view-history', animal)"
        class="btn-secondary text-xs px-3 py-1.5 flex-1"
      >
        📋 Ver historial
      </button>
      <button
        type="button"
        @click="emit('new-consultation', animal)"
        class="btn-primary text-xs px-3 py-1.5 flex-1"
      >
        ➕ Nueva consulta
      </button>
    </div>
  </div>
</template>
