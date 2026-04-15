<script setup>
import { ref } from 'vue'
import AnimalCard from './AnimalCard.vue'
import AnimalClinicalHistory from './AnimalClinicalHistory.vue'
import NewConsultationModal from './NewConsultationModal.vue'

const props = defineProps({
  client: { type: Object, required: true },
  animals: { type: Array, default: () => [] },
})

const emit = defineEmits(['logout'])

const selectedAnimal = ref(null)
const showModal = ref(false)
const modalAnimal = ref(null)

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
    <div class="card p-6 mb-6">
      <div class="flex items-center gap-4">
        <div class="w-12 h-12 rounded-full bg-brand-600/20 flex items-center justify-center text-2xl">👤</div>
        <div class="flex-1">
          <h2 class="text-xl font-bold text-white">{{ client.name }}</h2>
          <p class="text-sm text-slate-400">{{ client.phone }} · {{ client.region }}, {{ client.comuna }}</p>
          <p v-if="client.email" class="text-sm text-slate-500">{{ client.email }}</p>
        </div>
        <button type="button" @click="emit('logout')" class="btn-secondary text-xs">
          ← Nueva búsqueda
        </button>
      </div>
    </div>

    <!-- Animals grid or selected history -->
    <div v-if="!selectedAnimal">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-semibold text-white">
          🐾 Mis mascotas ({{ animals.length }})
        </h3>
      </div>

      <div v-if="animals.length === 0" class="card p-8 text-center">
        <span class="text-4xl mb-3 block">🐾</span>
        <p class="text-slate-400">No tienes mascotas registradas</p>
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
        class="mb-4 text-sm text-brand-400 hover:text-brand-300 transition-colors flex items-center gap-1"
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
