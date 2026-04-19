<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import AnimalCard from './AnimalCard.vue'
import AnimalClinicalHistory from './AnimalClinicalHistory.vue'
import NewConsultationModal from './NewConsultationModal.vue'
import { gsap } from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

const props = defineProps({
  client: { type: Object, required: true },
  animals: { type: Array, default: () => [] },
})

const emit = defineEmits(['logout'])

const selectedAnimal = ref(null)
const showModal = ref(false)
const modalAnimal = ref(null)

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

onMounted(() => {
  if (prefersReducedMotion) return
  gsap.from('.dash-animate', {
    opacity: 0, y: 20, stagger: 0.1, duration: 0.5, delay: 0.05, ease: 'power2.out'
  })
})

// Total clinical records across all animals
const totalRecords = computed(() =>
  props.animals.reduce((acc, a) => acc + (a.clinical_records?.length ?? 0), 0)
)

// Animals with a pending next_visit_rec
const animalsWithReminder = computed(() =>
  props.animals.filter(a => a.clinical_records?.[0]?.next_visit_rec)
)

function handleViewHistory(animal) {
  selectedAnimal.value = animal
  // Scroll to top of dashboard on mobile
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

function handleNewConsultation(animal) {
  modalAnimal.value = animal
  showModal.value = true
}

function handleConsultationSuccess() {
  showModal.value = false
}

function handleBack() {
  selectedAnimal.value = null
}
</script>

<template>
  <div>

    <!-- ── Client header ──────────────────────────────── -->
    <div class="card p-5 mb-5 dash-animate">
      <div class="flex flex-col sm:flex-row sm:items-center gap-4">

        <!-- Avatar -->
        <div
          class="w-14 h-14 rounded-2xl flex items-center justify-center flex-shrink-0 text-xl font-bold text-white"
          style="background-color: var(--btn-primary-bg);"
          aria-hidden="true"
        >
          {{ client.name?.charAt(0)?.toUpperCase() || '?' }}
        </div>

        <!-- Client info -->
        <div class="flex-1 min-w-0">
          <h2 class="text-lg font-bold mb-1.5 truncate" style="color: var(--text-primary);">
            {{ client.name }}
          </h2>
          <div class="flex flex-wrap gap-2">
            <span
              class="inline-flex items-center gap-1 text-xs font-medium px-2.5 py-1 rounded-full"
              style="background-color: var(--brand-alpha); color: var(--text-secondary); border: 1px solid var(--border-color);"
            >
              📱 {{ client.phone }}
            </span>
            <span
              v-if="client.email"
              class="inline-flex items-center gap-1 text-xs font-medium px-2.5 py-1 rounded-full"
              style="background-color: var(--brand-alpha); color: var(--text-secondary); border: 1px solid var(--border-color);"
            >
              ✉️ {{ client.email }}
            </span>
            <span
              v-if="client.region || client.comuna"
              class="inline-flex items-center gap-1 text-xs font-medium px-2.5 py-1 rounded-full"
              style="background-color: var(--brand-alpha); color: var(--text-secondary); border: 1px solid var(--border-color);"
            >
              📍 {{ [client.comuna, client.region].filter(Boolean).join(', ') }}
            </span>
          </div>
        </div>

        <!-- Actions -->
        <button
          type="button"
          @click="emit('logout')"
          class="btn-secondary text-sm self-start sm:self-center flex items-center gap-1.5 flex-shrink-0"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
          </svg>
          Nueva búsqueda
        </button>
      </div>
    </div>

    <!-- ── Summary stats ──────────────────────────────── -->
    <div v-if="animals.length > 0" class="grid grid-cols-3 gap-3 mb-5 dash-animate">
      <div class="card p-4 text-center">
        <p class="text-2xl font-bold" style="color: var(--btn-primary-bg);">{{ animals.length }}</p>
        <p class="text-xs mt-0.5" style="color: var(--text-muted);">
          Mascota{{ animals.length !== 1 ? 's' : '' }}
        </p>
      </div>
      <div class="card p-4 text-center">
        <p class="text-2xl font-bold" style="color: var(--btn-primary-bg);">{{ totalRecords }}</p>
        <p class="text-xs mt-0.5" style="color: var(--text-muted);">Consultas totales</p>
      </div>
      <div class="card p-4 text-center">
        <p class="text-2xl font-bold" style="color: animalsWithReminder.length > 0 ? '#f59e0b' : 'var(--btn-primary-bg)';">
          {{ animalsWithReminder.length }}
        </p>
        <p class="text-xs mt-0.5" style="color: var(--text-muted);">Con recomendación pendiente</p>
      </div>
    </div>

    <!-- ── Pending reminders banner ───────────────────── -->
    <div
      v-if="!selectedAnimal && animalsWithReminder.length > 0"
      class="rounded-xl p-4 mb-5 dash-animate"
      style="background-color: rgba(245,158,11,0.1); border: 1px solid rgba(245,158,11,0.25);"
    >
      <div class="flex items-start gap-3">
        <span class="text-xl flex-shrink-0" aria-hidden="true">🔔</span>
        <div>
          <p class="text-sm font-semibold mb-1" style="color: var(--text-primary);">
            Visitas recomendadas pendientes
          </p>
          <div class="space-y-1">
            <div
              v-for="a in animalsWithReminder"
              :key="a.id"
              class="text-xs flex items-center gap-2"
              style="color: var(--text-secondary);"
            >
              <span>🐾 <strong>{{ a.name }}</strong>:</span>
              <span class="truncate">{{ a.clinical_records[0].next_visit_rec }}</span>
              <button
                type="button"
                @click="handleNewConsultation(a)"
                class="ml-auto text-xs font-semibold flex-shrink-0 underline underline-offset-2 transition-opacity hover:opacity-70"
                style="color: var(--btn-primary-bg);"
              >
                Agendar
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ══ ANIMAL LIST VIEW ══════════════════════════════ -->
    <div v-if="!selectedAnimal">

      <!-- Section heading -->
      <div class="flex items-center justify-between mb-4 dash-animate">
        <h3 class="text-base font-bold flex items-center gap-2" style="color: var(--text-primary);">
          Mis mascotas
          <span
            class="inline-flex items-center justify-center w-5 h-5 rounded-full text-xs font-bold text-white"
            style="background-color: var(--btn-primary-bg);"
          >
            {{ animals.length }}
          </span>
        </h3>
        <RouterLink
          to="/solicitar"
          class="btn-primary text-xs px-3 py-1.5"
        >
          ➕ Nueva mascota
        </RouterLink>
      </div>

      <!-- Empty state -->
      <div v-if="animals.length === 0" class="card p-10 text-center dash-animate">
        <div
          class="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-4 text-3xl"
          style="background-color: var(--brand-alpha);"
          aria-hidden="true"
        >
          🐾
        </div>
        <p class="text-base font-semibold mb-1" style="color: var(--text-primary);">
          Sin mascotas registradas
        </p>
        <p class="text-sm mb-5" style="color: var(--text-muted);">
          Aún no hay animales asociados a tu cuenta. Solicita tu primera visita para registrarlos.
        </p>
        <RouterLink to="/solicitar" class="btn-primary inline-flex text-sm">
          Solicitar primera visita
        </RouterLink>
      </div>

      <!-- Animals grid -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <AnimalCard
          v-for="animal in animals"
          :key="animal.id"
          :animal="animal"
          class="dash-animate"
          @view-history="handleViewHistory"
          @new-consultation="handleNewConsultation"
        />
      </div>
    </div>

    <!-- ══ ANIMAL DETAIL VIEW ════════════════════════════ -->
    <div v-else>
      <!-- Back navigation -->
      <div class="flex items-center gap-3 mb-5 dash-animate">
        <button
          type="button"
          @click="handleBack"
          class="flex items-center gap-2 text-sm font-semibold transition-opacity hover:opacity-70"
          style="color: var(--btn-primary-bg);"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
          </svg>
          Volver a mascotas
        </button>

        <!-- Animal mini-selector if multiple animals -->
        <div v-if="animals.length > 1" class="ml-auto flex items-center gap-1.5 flex-wrap justify-end">
          <button
            v-for="a in animals"
            :key="a.id"
            type="button"
            @click="selectedAnimal = a"
            class="text-xs px-2.5 py-1 rounded-full font-medium transition-all"
            :style="selectedAnimal?.id === a.id
              ? 'background-color: var(--btn-primary-bg); color: #fff;'
              : 'background-color: var(--brand-alpha); color: var(--text-secondary); border: 1px solid var(--border-color);'"
          >
            {{ a.name }}
          </button>
        </div>
      </div>

      <!-- Clinical history with full profile -->
      <AnimalClinicalHistory
        :animal="selectedAnimal"
        @request-visit="handleNewConsultation"
      />
    </div>

    <!-- ── New consultation modal ─────────────────────── -->
    <NewConsultationModal
      :show="showModal"
      :client="client"
      :animal="modalAnimal"
      @close="showModal = false"
      @success="handleConsultationSuccess"
    />

  </div>
</template>
