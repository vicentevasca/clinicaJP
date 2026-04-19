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
    :class="[
      'card p-5 transition-all duration-200 cursor-pointer border-2',
      selected
        ? 'border-[var(--btn-primary-bg)]'
        : 'border-transparent hover:border-[var(--card-hover-border)]'
    ]"
    style="transition: box-shadow 0.2s, transform 0.2s, border-color 0.2s;"
    @click="emit('view-history', animal)"
    @mouseenter="$event.currentTarget.style.boxShadow = '0 4px 16px rgba(0,0,0,0.08)'; $event.currentTarget.style.transform = 'scale(1.012)'"
    @mouseleave="$event.currentTarget.style.boxShadow = ''; $event.currentTarget.style.transform = ''"
  >
    <div class="flex items-start gap-4">

      <!-- Avatar: large emoji in colored circle -->
      <div
        class="w-14 h-14 rounded-2xl flex items-center justify-center text-3xl flex-shrink-0"
        style="background-color: var(--brand-alpha); border: 1.5px solid var(--border-color);"
        aria-hidden="true"
      >
        {{ speciesEmoji[animal.species] || '🐾' }}
      </div>

      <!-- Info -->
      <div class="flex-1 min-w-0">
        <div class="flex items-center justify-between gap-2 mb-1">
          <h3 class="text-base font-bold truncate" style="color: var(--text-primary);">
            {{ animal.name }}
          </h3>
          <!-- Record count badge -->
          <span
            v-if="recordCount > 0"
            class="inline-flex items-center gap-1 text-xs font-semibold px-2 py-0.5 rounded-full flex-shrink-0"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg); border: 1px solid var(--border-color);"
            :title="`${recordCount} registro${recordCount !== 1 ? 's' : ''} clínico${recordCount !== 1 ? 's' : ''}`"
          >
            📋 {{ recordCount }}
          </span>
        </div>

        <!-- Species + breed + sex row -->
        <div class="flex items-center flex-wrap gap-1.5 mb-2">
          <span
            class="text-xs px-2 py-0.5 rounded-full capitalize font-medium"
            style="background-color: var(--bg-secondary); color: var(--text-secondary); border: 1px solid var(--border-color);"
          >
            {{ animal.species }}
          </span>
          <span
            v-if="animal.breed"
            class="text-xs"
            style="color: var(--text-muted);"
          >
            · {{ animal.breed }}
          </span>
          <span
            v-if="animal.sex && animal.sex !== 'desconocido'"
            class="text-xs capitalize"
            style="color: var(--text-muted);"
          >
            · {{ animal.sex }}
          </span>
          <span
            v-if="animal.birth_date"
            class="text-xs"
            style="color: var(--text-muted);"
          >
            · {{ new Date().getFullYear() - new Date(animal.birth_date).getFullYear() }} años
          </span>
        </div>

        <!-- Last diagnosis — 1 line truncated -->
        <div
          v-if="lastRecord"
          class="text-xs truncate"
          style="color: var(--text-muted);"
          :title="lastRecord.diagnosis || 'Sin diagnóstico'"
        >
          Último dx: {{ lastRecord.diagnosis || 'Sin diagnóstico' }}
        </div>
        <div
          v-else
          class="text-xs"
          style="color: var(--text-muted); opacity: 0.55;"
        >
          Sin registros clínicos aún
        </div>
      </div>
    </div>

    <!-- Actions -->
    <div class="mt-4 flex gap-2" @click.stop>
      <button
        type="button"
        @click="emit('view-history', animal)"
        class="btn-secondary text-xs px-3 py-1.5 flex-1 justify-center"
      >
        📋 Ver historial
      </button>
      <button
        type="button"
        @click="emit('new-consultation', animal)"
        class="btn-primary text-xs px-3 py-1.5 flex-1 justify-center"
      >
        ➕ Nueva consulta
      </button>
    </div>
  </div>
</template>
