<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { gsap } from 'gsap'
import { storeToRefs } from 'pinia'
import { useLeadsStore } from '@/stores/leads'
import LeadsColumn from '@/components/leads/LeadsColumn.vue'
import LeadFormModal from '@/components/leads/LeadFormModal.vue'
import { LEAD_STATUS, LEAD_STATUS_LABELS, SERVICE_TYPES, PRIORITY_LEVELS } from '@/utils/constants'

const router = useRouter()
const store  = useLeadsStore()
const { items: leads, loading, byStatus } = storeToRefs(store)

const showForm   = ref(false)
const editLead   = ref(null)
const filterSearch   = ref('')
const filterService   = ref('')
const filterPriority  = ref('')

// Computed que retorna una función para filtrar por columna
const filteredByStatus = (status) => byStatus.value[status].filter(l => {
  const s = filterSearch.value.toLowerCase()
  const matchSearch = !s ||
    l.client?.name?.toLowerCase().includes(s) ||
    l.animal?.name?.toLowerCase().includes(s) ||
    l.service_type?.toLowerCase().includes(s)
  const matchService = !filterService.value || l.service_type === filterService.value
  const matchPriority = !filterPriority.value || l.priority === filterPriority.value
  return matchSearch && matchService && matchPriority
})

const columns = [
  { status: LEAD_STATUS.WAITING,     title: 'En espera',   accent: 'border-amber-500', color: 'bg-amber-500' },
  { status: LEAD_STATUS.IN_PROGRESS, title: 'En curso',   accent: 'border-blue-500',  color: 'bg-blue-500'  },
  { status: LEAD_STATUS.DONE,        title: 'Cerrados',    accent: 'border-brand-500', color: 'bg-brand-500' },
  { status: LEAD_STATUS.CANCELLED,  title: 'Cancelados',  accent: 'border-slate-500', color: 'bg-slate-500' },
]

onMounted(async () => {
  await store.fetchAll()
  gsap.from('.stagger-item', { opacity: 0, y: 20, stagger: 0.05, duration: 0.4, delay: 0.1 })
})

function openLead(lead) {
  router.push(`/app/leads/${lead.id}`)
}

function closeForm() {
  showForm.value = false
}
</script>

<template>
  <div class="p-6 space-y-4">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
      <div>
        <h1 class="text-2xl font-bold text-white">Leads</h1>
        <p class="text-slate-400 text-sm">Pipeline de solicitudes</p>
      </div>
      <button class="btn-primary" @click="showForm = true; editLead = null">
        + Nuevo lead
      </button>
    </div>

    <!-- Filtros -->
    <div class="flex flex-wrap gap-3">
      <input v-model="filterSearch" type="text" placeholder="Buscar..."
        class="input-base max-w-xs" />
      <select v-model="filterService" class="input-base max-w-[160px]">
        <option value="">Todos servicios</option>
        <option v-for="s in SERVICE_TYPES" :key="s.value" :value="s.value">{{ s.label }}</option>
      </select>
      <select v-model="filterPriority" class="input-base max-w-[140px]">
        <option value="">Todas prioridades</option>
        <option v-for="p in PRIORITY_LEVELS" :key="p.value" :value="p.value">{{ p.label }}</option>
      </select>
    </div>

    <!-- Kanban -->
    <div v-if="loading" class="text-center py-12 text-slate-500">Cargando...</div>
    <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
      <div v-for="col in columns" :key="col.status"
        class="card p-4 flex flex-col stagger-item">
        <LeadsColumn
          :title="col.title"
          :leads="filteredByStatus(col.status)"
          :accent-color="col.accent"
          @lead-click="openLead"
        />
      </div>
    </div>

    <LeadFormModal
      :show="showForm"
      :lead="editLead"
      @close="closeForm"
      @saved="store.fetchAll()"
    />
  </div>
</template>
