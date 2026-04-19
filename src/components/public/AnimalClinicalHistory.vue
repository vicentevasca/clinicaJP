<script setup>
import { computed, ref } from 'vue'
import { RouterLink } from 'vue-router'

const props = defineProps({
  animal: { type: Object, required: true },
})

const emit = defineEmits(['request-visit'])

const activeTab = ref('history')

const speciesEmoji = {
  perro: '🐕', gato: '🐈', ave: '🐦', gallina: '🐔',
  caballo: '🐴', bovino: '🐄', otro: '🐾',
}

const records = computed(() =>
  [...(props.animal.clinical_records || [])].sort(
    (a, b) => new Date(b.created_at) - new Date(a.created_at)
  )
)

const age = computed(() => {
  if (!props.animal.birth_date) return null
  const diff = new Date() - new Date(props.animal.birth_date)
  const years = Math.floor(diff / (1000 * 60 * 60 * 24 * 365.25))
  const months = Math.floor((diff % (1000 * 60 * 60 * 24 * 365.25)) / (1000 * 60 * 60 * 24 * 30.44))
  return years > 0 ? `${years} año${years !== 1 ? 's' : ''}` : `${months} mes${months !== 1 ? 'es' : ''}`
})

const lastWeight = computed(() =>
  records.value.find(r => r.weight_kg)?.weight_kg ?? props.animal.weight_kg ?? null
)

const lastVisitDate = computed(() => records.value[0]?.created_at ?? null)

const nextRecommendation = computed(() => records.value[0]?.next_visit_rec ?? null)

// Detect vaccine-related records by keywords
const VACCINE_KEYWORDS = [
  'vacun', 'antirrábic', 'parvovirus', 'moquillo', 'leptospir',
  'hepatitis', 'bordetella', 'leucemia', 'calicivirus', 'rinotraqueitis',
  'rabia', 'triple felina', 'quintuple', 'sextuple',
]
const vaccineRecords = computed(() =>
  records.value.filter(r => {
    const text = `${r.diagnosis || ''} ${r.treatment || ''} ${r.prescriptions || ''}`.toLowerCase()
    return VACCINE_KEYWORDS.some(kw => text.includes(kw))
  })
)

const weightHistory = computed(() =>
  records.value
    .filter(r => r.weight_kg)
    .map(r => ({ date: r.created_at, weight: parseFloat(r.weight_kg) }))
)

const maxWeight = computed(() => Math.max(...weightHistory.value.map(w => w.weight), 1))

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleDateString('es-CL', {
    day: '2-digit', month: 'short', year: 'numeric',
  })
}

const tabs = [
  { key: 'history',  label: 'Historial clínico', icon: '📋' },
  { key: 'vaccines', label: 'Vacunas',            icon: '💉' },
  { key: 'weight',   label: 'Historial de peso',  icon: '⚖️' },
]
</script>

<template>
  <div class="space-y-5">

    <!-- ── Animal profile header ─────────────────────── -->
    <div class="card p-5">
      <div class="flex items-start gap-4">
        <!-- Species avatar -->
        <div
          class="w-16 h-16 rounded-2xl flex items-center justify-center text-3xl flex-shrink-0"
          style="background-color: var(--brand-alpha); border: 1.5px solid var(--border-color);"
          aria-hidden="true"
        >
          {{ speciesEmoji[animal.species] || '🐾' }}
        </div>

        <!-- Info -->
        <div class="flex-1 min-w-0">
          <h3 class="text-xl font-bold mb-1 truncate" style="color: var(--text-primary);">
            {{ animal.name }}
          </h3>

          <div class="flex flex-wrap gap-1.5 mb-3">
            <span
              class="text-xs px-2 py-0.5 rounded-full capitalize font-medium"
              style="background-color: var(--bg-secondary); color: var(--text-secondary); border: 1px solid var(--border-color);"
            >
              {{ animal.species }}
            </span>
            <span v-if="animal.breed" class="text-xs" style="color: var(--text-muted);">
              · {{ animal.breed }}
            </span>
            <span v-if="animal.sex && animal.sex !== 'desconocido'" class="text-xs capitalize" style="color: var(--text-muted);">
              · {{ animal.sex }}
            </span>
            <span v-if="age" class="text-xs" style="color: var(--text-muted);">
              · {{ age }}
            </span>
          </div>

          <!-- Vital tags -->
          <div class="flex flex-wrap gap-2">
            <span
              v-if="lastWeight"
              class="inline-flex items-center gap-1 text-xs font-semibold px-2 py-1 rounded-lg"
              style="background-color: var(--brand-alpha); color: var(--btn-primary-bg); border: 1px solid var(--border-color);"
            >
              ⚖️ {{ lastWeight }} kg
            </span>
            <span
              class="inline-flex items-center gap-1 text-xs font-semibold px-2 py-1 rounded-lg"
              style="background-color: var(--brand-alpha); color: var(--btn-primary-bg); border: 1px solid var(--border-color);"
            >
              📋 {{ records.length }} consulta{{ records.length !== 1 ? 's' : '' }}
            </span>
          </div>
        </div>

        <!-- Request visit CTA -->
        <button
          type="button"
          @click="emit('request-visit', animal)"
          class="btn-primary text-xs px-4 py-2 flex-shrink-0 hidden sm:inline-flex"
        >
          ➕ Nueva consulta
        </button>
      </div>

      <!-- Mobile CTA -->
      <button
        type="button"
        @click="emit('request-visit', animal)"
        class="btn-primary text-sm w-full justify-center mt-4 sm:hidden"
      >
        ➕ Solicitar nueva consulta
      </button>
    </div>

    <!-- ── Quick stats ────────────────────────────────── -->
    <div v-if="records.length > 0" class="grid grid-cols-2 sm:grid-cols-3 gap-3">
      <div class="card p-4 text-center">
        <p class="text-2xl font-bold mb-0.5" style="color: var(--btn-primary-bg);">{{ records.length }}</p>
        <p class="text-xs" style="color: var(--text-muted);">Consultas totales</p>
      </div>
      <div class="card p-4 text-center">
        <p class="text-sm font-bold mb-0.5 leading-tight" style="color: var(--text-primary);">
          {{ lastVisitDate ? formatDate(lastVisitDate) : '—' }}
        </p>
        <p class="text-xs" style="color: var(--text-muted);">Última visita</p>
      </div>
      <div class="card p-4 text-center col-span-2 sm:col-span-1">
        <p
          class="text-xs font-semibold leading-snug line-clamp-2 mb-0.5"
          :style="nextRecommendation ? 'color: var(--btn-primary-bg);' : 'color: var(--text-muted);'"
        >
          {{ nextRecommendation || 'Sin indicación pendiente' }}
        </p>
        <p class="text-xs" style="color: var(--text-muted);">Próxima recomendación</p>
      </div>
    </div>

    <!-- Próxima visita alert -->
    <div
      v-if="nextRecommendation"
      class="flex items-start gap-3 p-4 rounded-xl"
      style="background-color: var(--brand-alpha); border: 1px solid var(--border-color);"
    >
      <span class="text-xl flex-shrink-0" aria-hidden="true">📅</span>
      <div>
        <p class="text-sm font-semibold mb-0.5" style="color: var(--text-primary);">Próxima visita recomendada</p>
        <p class="text-sm" style="color: var(--text-secondary);">{{ nextRecommendation }}</p>
        <button
          type="button"
          @click="emit('request-visit', animal)"
          class="mt-2 text-xs font-semibold underline underline-offset-2 transition-opacity hover:opacity-70"
          style="color: var(--btn-primary-bg);"
        >
          Agendar ahora →
        </button>
      </div>
    </div>

    <!-- ── Tab bar ────────────────────────────────────── -->
    <div
      class="flex rounded-xl p-1"
      style="background-color: var(--bg-secondary); border: 1px solid var(--border-color);"
    >
      <button
        v-for="tab in tabs"
        :key="tab.key"
        type="button"
        @click="activeTab = tab.key"
        class="flex-1 py-2 px-2 rounded-lg text-xs font-semibold transition-all duration-200 flex items-center justify-center gap-1.5 truncate"
        :style="activeTab === tab.key
          ? 'background-color: var(--btn-primary-bg); color: #fff; box-shadow: 0 1px 4px var(--btn-primary-shadow);'
          : 'background-color: transparent; color: var(--text-muted);'"
      >
        <span aria-hidden="true">{{ tab.icon }}</span>
        <span class="hidden sm:inline">{{ tab.label }}</span>
        <span class="sm:hidden">{{ tab.label.split(' ')[0] }}</span>
      </button>
    </div>

    <!-- ── Tab: Historial clínico ─────────────────────── -->
    <div v-if="activeTab === 'history'">
      <!-- Empty state -->
      <div v-if="records.length === 0" class="card p-10 text-center">
        <span class="text-4xl mb-3 block" aria-hidden="true">📭</span>
        <p class="font-semibold mb-1" style="color: var(--text-primary);">Sin registros clínicos</p>
        <p class="text-sm mb-5" style="color: var(--text-muted);">
          Los registros se crean al finalizar cada visita
        </p>
        <button
          type="button"
          @click="emit('request-visit', animal)"
          class="btn-primary text-sm inline-flex"
        >
          Solicitar primera visita
        </button>
      </div>

      <!-- Timeline -->
      <div v-else class="relative">
        <!-- Vertical line -->
        <div class="absolute left-5 top-2 bottom-2 w-px" style="background-color: var(--border-color);" aria-hidden="true" />

        <div
          v-for="(record, i) in records"
          :key="record.id"
          class="relative pl-12 pb-5 last:pb-0"
        >
          <!-- Timeline dot -->
          <div
            class="absolute left-[14px] top-1.5 w-3 h-3 rounded-full"
            :style="i === 0
              ? 'background-color: var(--btn-primary-bg); border: 2px solid var(--bg-card);'
              : 'background-color: var(--border-color); border: 2px solid var(--bg-card);'"
            aria-hidden="true"
          />

          <!-- Record card -->
          <div class="card p-4">
            <!-- Header row -->
            <div class="flex items-center justify-between gap-2 mb-3">
              <div class="flex items-center gap-2">
                <span
                  class="text-xs font-bold px-2 py-0.5 rounded-full"
                  :style="i === 0
                    ? 'background-color: var(--btn-primary-bg); color: #fff;'
                    : 'background-color: var(--brand-alpha); color: var(--btn-primary-bg); border: 1px solid var(--border-color);'"
                >
                  {{ formatDate(record.created_at) }}
                </span>
                <span v-if="i === 0" class="text-xs font-medium" style="color: var(--text-muted);">Última visita</span>
              </div>
              <span v-if="record.visit" class="text-xs" style="color: var(--text-muted);">
                {{ record.visit.status === 'completed' ? '✅ Completada' : '📅 Programada' }}
              </span>
            </div>

            <!-- Vitals row -->
            <div v-if="record.weight_kg || record.temperature_c" class="flex gap-4 mb-3 pb-3" style="border-bottom: 1px solid var(--border-color);">
              <div v-if="record.weight_kg" class="flex items-center gap-1.5 text-xs">
                <span aria-hidden="true">⚖️</span>
                <span style="color: var(--text-muted);">Peso:</span>
                <span class="font-semibold" style="color: var(--text-primary);">{{ record.weight_kg }} kg</span>
              </div>
              <div v-if="record.temperature_c" class="flex items-center gap-1.5 text-xs">
                <span aria-hidden="true">🌡️</span>
                <span style="color: var(--text-muted);">Temp:</span>
                <span class="font-semibold" style="color: var(--text-primary);">{{ record.temperature_c }} °C</span>
              </div>
            </div>

            <!-- Fields -->
            <div class="space-y-2.5">
              <div v-if="record.diagnosis">
                <p class="text-xs uppercase tracking-wide font-semibold mb-0.5" style="color: var(--text-muted);">Diagnóstico</p>
                <p class="text-sm" style="color: var(--text-primary);">{{ record.diagnosis }}</p>
              </div>
              <div v-if="record.treatment">
                <p class="text-xs uppercase tracking-wide font-semibold mb-0.5" style="color: var(--text-muted);">Tratamiento</p>
                <p class="text-sm" style="color: var(--text-primary);">{{ record.treatment }}</p>
              </div>
              <div v-if="record.prescriptions">
                <p class="text-xs uppercase tracking-wide font-semibold mb-0.5" style="color: var(--text-muted);">Prescripciones / Vacunas</p>
                <p class="text-sm" style="color: var(--text-primary);">{{ record.prescriptions }}</p>
              </div>
              <div v-if="record.observations">
                <p class="text-xs uppercase tracking-wide font-semibold mb-0.5" style="color: var(--text-muted);">Observaciones</p>
                <p class="text-sm" style="color: var(--text-secondary);">{{ record.observations }}</p>
              </div>
            </div>

            <!-- Next visit recommendation -->
            <div
              v-if="record.next_visit_rec"
              class="mt-3 pt-3 flex items-start gap-2"
              style="border-top: 1px solid var(--border-color);"
            >
              <span class="text-sm flex-shrink-0" aria-hidden="true">📅</span>
              <div>
                <p class="text-xs font-semibold mb-0.5" style="color: var(--text-muted);">Próxima visita recomendada</p>
                <p class="text-sm font-medium" style="color: var(--btn-primary-bg);">{{ record.next_visit_rec }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ── Tab: Vacunas ───────────────────────────────── -->
    <div v-else-if="activeTab === 'vaccines'">
      <!-- Info banner -->
      <div
        class="flex items-start gap-3 p-4 rounded-xl mb-4 text-sm"
        style="background-color: var(--brand-alpha); border: 1px solid var(--border-color);"
      >
        <span class="flex-shrink-0 text-base" aria-hidden="true">ℹ️</span>
        <p style="color: var(--text-secondary);">
          Se muestran las consultas que contienen menciones a vacunas o esquemas de inmunización.
        </p>
      </div>

      <!-- No vaccines found -->
      <div v-if="vaccineRecords.length === 0" class="card p-10 text-center">
        <span class="text-4xl mb-3 block" aria-hidden="true">💉</span>
        <p class="font-semibold mb-1" style="color: var(--text-primary);">Sin vacunas registradas</p>
        <p class="text-sm mb-5" style="color: var(--text-muted);">
          No encontramos registros de vacunación para {{ animal.name }}
        </p>
        <button
          type="button"
          @click="emit('request-visit', animal)"
          class="btn-primary text-sm inline-flex"
        >
          Solicitar vacunación
        </button>
      </div>

      <!-- Vaccine list -->
      <div v-else class="space-y-3">
        <div
          v-for="record in vaccineRecords"
          :key="record.id"
          class="card p-4"
        >
          <div class="flex items-start gap-3">
            <div
              class="w-9 h-9 rounded-xl flex items-center justify-center text-lg flex-shrink-0 mt-0.5"
              style="background-color: var(--brand-alpha);"
              aria-hidden="true"
            >
              💉
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center justify-between gap-2 mb-2">
                <span
                  class="text-xs font-bold px-2 py-0.5 rounded-full"
                  style="background-color: var(--brand-alpha); color: var(--btn-primary-bg); border: 1px solid var(--border-color);"
                >
                  {{ formatDate(record.created_at) }}
                </span>
              </div>
              <div class="space-y-1.5">
                <div v-if="record.prescriptions">
                  <p class="text-xs uppercase tracking-wide font-semibold mb-0.5" style="color: var(--text-muted);">Vacuna(s) / Prescripción</p>
                  <p class="text-sm" style="color: var(--text-primary);">{{ record.prescriptions }}</p>
                </div>
                <div v-if="record.treatment">
                  <p class="text-xs uppercase tracking-wide font-semibold mb-0.5" style="color: var(--text-muted);">Tratamiento</p>
                  <p class="text-sm" style="color: var(--text-secondary);">{{ record.treatment }}</p>
                </div>
                <div v-if="record.next_visit_rec" class="flex items-center gap-1.5 mt-2 pt-2" style="border-top: 1px solid var(--border-color);">
                  <span class="text-xs" aria-hidden="true">📅</span>
                  <p class="text-xs font-medium" style="color: var(--btn-primary-bg);">
                    Refuerzo: {{ record.next_visit_rec }}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ── Tab: Peso ──────────────────────────────────── -->
    <div v-else-if="activeTab === 'weight'">
      <!-- No weight data -->
      <div v-if="weightHistory.length === 0" class="card p-10 text-center">
        <span class="text-4xl mb-3 block" aria-hidden="true">⚖️</span>
        <p class="font-semibold mb-1" style="color: var(--text-primary);">Sin historial de peso</p>
        <p class="text-sm" style="color: var(--text-muted);">
          El peso se registra durante cada consulta veterinaria
        </p>
      </div>

      <!-- Weight history -->
      <div v-else>
        <!-- Current weight highlight -->
        <div class="card p-5 mb-4 flex items-center gap-5">
          <div
            class="w-14 h-14 rounded-2xl flex items-center justify-center text-2xl flex-shrink-0"
            style="background-color: var(--brand-alpha);"
            aria-hidden="true"
          >
            ⚖️
          </div>
          <div>
            <p class="text-3xl font-bold" style="color: var(--btn-primary-bg);">
              {{ weightHistory[0].weight }} <span class="text-base font-medium" style="color: var(--text-muted);">kg</span>
            </p>
            <p class="text-sm" style="color: var(--text-muted);">Peso actual · {{ formatDate(weightHistory[0].date) }}</p>
          </div>
          <div v-if="weightHistory.length > 1" class="ml-auto text-right">
            <p
              class="text-sm font-semibold"
              :style="weightHistory[0].weight >= weightHistory[1].weight ? 'color: var(--text-success, #16a34a);' : 'color: #ef4444;'"
            >
              {{ weightHistory[0].weight >= weightHistory[1].weight ? '↑' : '↓' }}
              {{ Math.abs(weightHistory[0].weight - weightHistory[1].weight).toFixed(1) }} kg
            </p>
            <p class="text-xs" style="color: var(--text-muted);">vs visita anterior</p>
          </div>
        </div>

        <!-- Weight table with visual bars -->
        <div class="card overflow-hidden">
          <div class="px-4 py-3" style="border-bottom: 1px solid var(--border-color);">
            <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--text-muted);">Evolución de peso</p>
          </div>
          <div class="divide-y" style="border-color: var(--border-color);">
            <div
              v-for="(entry, i) in weightHistory"
              :key="entry.date"
              class="px-4 py-3 flex items-center gap-4"
            >
              <!-- Date -->
              <span class="text-xs w-24 flex-shrink-0" style="color: var(--text-muted);">
                {{ formatDate(entry.date) }}
              </span>
              <!-- Bar -->
              <div class="flex-1 h-2 rounded-full overflow-hidden" style="background-color: var(--bg-secondary);">
                <div
                  class="h-full rounded-full transition-all duration-500"
                  :style="{
                    width: `${(entry.weight / maxWeight) * 100}%`,
                    backgroundColor: i === 0 ? 'var(--btn-primary-bg)' : 'var(--border-muted, #a7f3d0)',
                  }"
                />
              </div>
              <!-- Value -->
              <span
                class="text-sm font-semibold w-14 text-right flex-shrink-0"
                :style="i === 0 ? 'color: var(--btn-primary-bg);' : 'color: var(--text-primary);'"
              >
                {{ entry.weight }} kg
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ── Bottom CTA ─────────────────────────────────── -->
    <div
      class="card p-5 flex flex-col sm:flex-row items-center justify-between gap-4"
      style="border-left: 3px solid var(--btn-primary-bg);"
    >
      <div>
        <p class="font-semibold text-sm" style="color: var(--text-primary);">¿Necesita una nueva atención?</p>
        <p class="text-xs mt-0.5" style="color: var(--text-muted);">Te contactamos en menos de 2 horas hábiles</p>
      </div>
      <button
        type="button"
        @click="emit('request-visit', animal)"
        class="btn-primary text-sm px-6 flex-shrink-0"
      >
        Solicitar visita →
      </button>
    </div>

  </div>
</template>
