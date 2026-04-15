<script setup>
import { ref, onMounted } from 'vue'
import AnimalCard from './AnimalCard.vue'
import AnimalClinicalHistory from './AnimalClinicalHistory.vue'
import NewConsultationModal from './NewConsultationModal.vue'
import { gsap } from 'gsap'

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
  gsap.from('.animate-in', { opacity: 0, y: 20, stagger: 0.12, duration: 0.5, delay: 0.1 })
})

function handleViewHistory(animal) {
  selectedAnimal.value = animal
}

function handleNewConsultation(animal) {
  modalAnimal.value = animal
  showModal.value = true
}

function handleConsultationSuccess() {
  showModal.value = false
  // Could trigger a refresh of animals here
}
</script>

<template>
  <div>
    <!-- Client header -->
    <div class="card p-6 mb-6 animate-in">
      <div class="flex items-center gap-4">
        <div class="w-12 h-12 rounded-full bg-[var(--brand-alpha)] flex items-center justify-center text-2xl">
          <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 text-[var(--btn-primary-bg)]" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" role="img" :aria-label="client.name">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
          </svg>
        </div>
        <div class="flex-1">
          <h2 class="text-xl font-semibold text-[var(--text-primary)]">{{ client.name }}</h2>
          <p class="text-sm text-[var(--text-muted)]">{{ client.phone }} · {{ client.region }}, {{ client.comuna }}</p>
          <p v-if="client.email" class="text-sm text-[var(--text-muted)]">{{ client.email }}</p>
        </div>
        <button type="button" @click="emit('logout')" class="btn-secondary text-xs">
          ← Nueva búsqueda
        </button>
      </div>
    </div>

    <!-- Animals grid or selected history -->
    <div v-if="!selectedAnimal">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-semibold text-[var(--text-primary)]">
          <span aria-hidden="true">🐾</span> Mis mascotas ({{ animals.length }})
        </h3>
      </div>

      <div v-if="animals.length === 0" class="card p-8 text-center">
        <svg xmlns="http://www.w3.org/2000/svg" class="w-12 h-12 text-[var(--btn-primary-bg)] mx-auto mb-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5" role="img" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5" />
        </svg>
        <p class="text-[var(--text-muted)]">No tienes mascotas registradas</p>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <AnimalCard
          v-for="animal in animals"
          :key="animal.id"
          :animal="animal"
          @view-history="handleViewHistory"
          @new-consultation="handleNewConsultation"
        />
      </div>
    </div>

    <!-- Animal clinical history view -->
    <div v-else>
      <button
        type="button"
        @click="selectedAnimal = null"
        class="mb-4 text-sm text-[var(--btn-primary-bg)] hover:opacity-80 transition-opacity flex items-center gap-1"
      >
        ← Volver a mascotas
      </button>
      <AnimalClinicalHistory :animal="selectedAnimal" />
    </div>

    <!-- New consultation modal -->
    <NewConsultationModal
      :show="showModal"
      :client="client"
      :animal="modalAnimal"
      @close="showModal = false"
      @success="handleConsultationSuccess"
    />
  </div>
</template>
