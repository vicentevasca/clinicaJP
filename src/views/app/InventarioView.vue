<script setup>
import { onMounted, ref, computed } from 'vue'
import { gsap } from 'gsap'
import { storeToRefs } from 'pinia'
import { useInventoryStore } from '@/stores/inventory'
import InsumoCard from '@/components/inventory/InsumoCard.vue'
import InsumoFormModal from '@/components/inventory/InsumoFormModal.vue'
import StockAlertBanner from '@/components/inventory/StockAlertBanner.vue'

const store = useInventoryStore()
const { items, loading, lowStockItems } = storeToRefs(store)

const activeTab    = ref('')
const search       = ref('')
const showForm     = ref(false)
const editItem     = ref(null)

const CATEGORIES = ['Todos', 'vacuna', 'farmaco', 'insumo', 'herramienta']

const filtered = computed(() => {
  return items.value.filter(item => {
    const matchTab  = !activeTab.value || item.category === activeTab.value
    const matchSearch = !search.value ||
      item.name?.toLowerCase().includes(search.value.toLowerCase()) ||
      item.supplier_name?.toLowerCase().includes(search.value.toLowerCase())
    return matchTab && matchSearch
  })
})

onMounted(async () => {
  await store.fetchAll()
  gsap.from('.stagger-item', { opacity: 0, y: 20, stagger: 0.05, duration: 0.4, delay: 0.1 })
})

function openEdit(item) {
  editItem.value = item
  showForm.value = true
}
</script>

<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-white">📦 Inventario</h1>
        <p class="text-slate-400 text-sm">{{ items.length }} insumos registrados</p>
      </div>
      <button class="btn-primary" @click="showForm = true; editItem = null">
        + Nuevo insumo
      </button>
    </div>

    <!-- Alerta de stock -->
    <StockAlertBanner :count="lowStockItems.length" />

    <!-- Tabs + búsqueda -->
    <div class="flex flex-wrap gap-3 items-center">
      <div class="flex gap-1 bg-slate-800/60 rounded-lg p-1">
        <button v-for="cat in CATEGORIES" :key="cat"
          @click="activeTab = cat === 'Todos' ? '' : cat"
          class="px-3 py-1.5 rounded-md text-xs font-medium transition-colors"
          :class="(cat === 'Todos' ? !activeTab : activeTab === cat)
            ? 'bg-brand-600 text-white'
            : 'text-slate-400 hover:text-slate-200'">
          {{ cat === 'Todos' ? 'Todos' : cat }}
        </button>
      </div>
      <input v-model="search" type="text" placeholder="Buscar..."
        class="input-base max-w-xs" />
    </div>

    <div v-if="loading" class="text-center py-12 text-slate-500">Cargando...</div>
    <div v-else-if="filtered.length === 0" class="text-center py-12 text-slate-500">
      No hay insumos que coincidan
    </div>
    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      <InsumoCard v-for="item in filtered" :key="item.id" :item="item"
        class="stagger-item"
        @click="openEdit(item)" />
    </div>

    <InsumoFormModal
      :show="showForm"
      :item="editItem"
      @close="showForm = false; editItem = null"
      @saved="store.fetchAll()"
    />
  </div>
</template>
