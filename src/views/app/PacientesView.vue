<script setup>
import { onMounted, ref, computed } from 'vue'
import { gsap } from 'gsap'
import { storeToRefs } from 'pinia'
import { usePatientsStore } from '@/stores/patients'
import PacienteCard from '@/components/clinical/PacienteCard.vue'
import { ANIMAL_SPECIES } from '@/utils/constants'

const store = usePatientsStore()
const { animals, loading } = storeToRefs(store)

const search = ref('')
const filterSpecies = ref('')

const filtered = computed(() => {
  return animals.value.filter(a => {
    const s = search.value.toLowerCase()
    const matchSearch = !s ||
      a.name?.toLowerCase().includes(s) ||
      a.client?.name?.toLowerCase().includes(s)
    const matchSpecies = !filterSpecies.value || a.species === filterSpecies.value
    return matchSearch && matchSpecies
  })
})

onMounted(async () => {
  await store.fetchAnimals()
  gsap.from('.stagger-item', { opacity: 0, y: 20, stagger: 0.05, duration: 0.4, delay: 0.1 })
})
</script>

<template>
  <div class="p-6 space-y-4">
    <div>
      <h1 class="text-2xl font-bold text-white">🐾 Pacientes</h1>
      <p class="text-slate-400 text-sm">Todos los animales registrados</p>
    </div>

    <!-- Filtros -->
    <div class="flex flex-wrap gap-3">
      <input v-model="search" type="text" placeholder="Buscar por nombre..."
        class="input-base max-w-xs" />
      <select v-model="filterSpecies" class="input-base max-w-[160px]">
        <option value="">Todas especies</option>
        <option v-for="s in ANIMAL_SPECIES" :key="s.value" :value="s.value">{{ s.label }}</option>
      </select>
    </div>

    <div v-if="loading" class="text-center py-12 text-slate-500">Cargando...</div>
    <div v-else-if="filtered.length === 0" class="text-center py-12 text-slate-500">
      No hay pacientes que coincidan
    </div>
    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      <PacienteCard v-for="animal in filtered" :key="animal.id" :animal="animal"
        class="stagger-item" />
    </div>
  </div>
</template>
