<script setup>
import { onMounted, ref, computed } from 'vue'
import { gsap } from 'gsap'
import { proceduresService } from '@/services/procedures.service'
import ProcedimientoCard from '@/components/procedures/ProcedimientoCard.vue'
import ProcedimientoFormModal from '@/components/procedures/ProcedimientoFormModal.vue'

const procedures = ref([])
const loading    = ref(true)
const search     = ref('')
const showForm   = ref(false)
const editItem   = ref(null)

const CATEGORIES = ['Todos','vacunacion','desparasitacion','chequeo','receta','corte_pelo','atencion_domicilio','otro']
const activeTab  = ref('Todos')

const filtered = computed(() => {
  return procedures.value.filter(p => {
    const matchTab = activeTab.value === 'Todos' || p.category === activeTab.value
    const matchSearch = !search.value ||
      p.name?.toLowerCase().includes(search.value.toLowerCase())
    return matchTab && matchSearch
  })
})

onMounted(async () => {
  try {
    procedures.value = await proceduresService.getAll()
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
  gsap.from('.stagger-item', { opacity: 0, y: 20, stagger: 0.05, duration: 0.4, delay: 0.1 })
})

async function refresh() {
  loading.value = true
  try {
    procedures.value = await proceduresService.getAll()
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-white">🩺 Procedimientos</h1>
        <p class="text-slate-400 text-sm">{{ procedures.length }} procedimientos</p>
      </div>
      <button class="btn-primary" @click="showForm = true; editItem = null">
        + Nuevo procedimiento
      </button>
    </div>

    <!-- Filtros -->
    <div class="flex flex-wrap gap-3 items-center">
      <div class="flex gap-1 bg-slate-800/60 rounded-lg p-1 overflow-x-auto">
        <button v-for="cat in CATEGORIES" :key="cat"
          @click="activeTab = cat"
          class="px-3 py-1.5 rounded-md text-xs font-medium transition-colors whitespace-nowrap"
          :class="activeTab === cat
            ? 'bg-brand-600 text-white'
            : 'text-slate-400 hover:text-slate-200'">
          {{ cat === 'Todos' ? 'Todos' : cat.replace('_',' ') }}
        </button>
      </div>
      <input v-model="search" type="text" placeholder="Buscar..."
        class="input-base max-w-xs" />
    </div>

    <div v-if="loading" class="text-center py-12 text-slate-500">Cargando...</div>
    <div v-else-if="filtered.length === 0" class="text-center py-12 text-slate-500">
      Sin procedimientos
    </div>
    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      <ProcedimientoCard v-for="p in filtered" :key="p.id" :procedure="p"
        class="stagger-item"
        @click="showForm = true; editItem = p" />
    </div>

    <ProcedimientoFormModal
      :show="showForm"
      :procedure="editItem"
      @close="showForm = false"
      @saved="refresh"
    />
  </div>
</template>
