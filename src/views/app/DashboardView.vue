<script setup>
import { onMounted, ref, computed } from 'vue'
import { gsap } from 'gsap'
import { storeToRefs } from 'pinia'
import { useLeadsStore } from '@/stores/leads'
import { useInventoryStore } from '@/stores/inventory'
import { useAgendaStore } from '@/stores/agenda'
import MetricCard from '@/components/dashboard/MetricCard.vue'
import AlertsPanel from '@/components/dashboard/AlertsPanel.vue'
import QuickActions from '@/components/dashboard/QuickActions.vue'
import RecentLeadsList from '@/components/dashboard/RecentLeadsList.vue'

const leadsStore     = useLeadsStore()
const inventoryStore = useInventoryStore()
const agendaStore    = useAgendaStore()

const { items: allLeads, loading: leadsLoading } = storeToRefs(leadsStore)
const { loading: inventoryLoading } = storeToRefs(inventoryStore)
const { loading: agendaLoading, visits } = storeToRefs(agendaStore)

// Métricas
const now  = new Date()
const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString()
const weekStart  = new Date(now - 7 * 24 * 60 * 60 * 1000).toISOString()
const monthStart = new Date(now - 30 * 24 * 60 * 60 * 1000).toISOString()

const leadsToday = computed(() =>
  allLeads.value.filter(l => new Date(l.created_at) >= new Date(todayStart)).length
)
const waitingLeads = computed(() => allLeads.value.filter(l => l.status === 'waiting').length)
const inProgressLeads = computed(() => allLeads.value.filter(l => l.status === 'in_progress').length)
const doneLeads = computed(() => allLeads.value.filter(l => l.status === 'done').length)
const visitsThisWeek = computed(() => visits.value.length)
const closureRate = computed(() => {
  const total = allLeads.value.length
  if (!total) return 0
  return Math.round((doneLeads.value / total) * 100)
})

const recentLeads = computed(() => allLeads.value.slice(0, 5))

onMounted(async () => {
  await Promise.all([
    leadsStore.fetchAll(),
    inventoryStore.fetchAll(),
    agendaStore.fetchByRange(weekStart, now.toISOString()),
  ])
  gsap.from('.animate-in', { opacity: 0, y: 15, stagger: 0.07, duration: 0.35 })
})
</script>

<template>
  <div class="p-6 space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-white">Dashboard</h1>
        <p class="text-slate-400 text-sm mt-0.5">Resumen de tu operación</p>
      </div>
      <QuickActions />
    </div>

    <!-- Métricas -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <MetricCard label="Leads hoy"       :value="leadsToday"     icon="📋" :loading="leadsLoading" />
      <MetricCard label="En espera"       :value="waitingLeads"  icon="⏳" :loading="leadsLoading" />
      <MetricCard label="Visitas semana"  :value="visitsThisWeek" icon="📅" :loading="agendaLoading" />
      <MetricCard label="Tasa de cierre"  :value="`${closureRate}%`" icon="✅" :loading="leadsLoading" />
    </div>

    <!-- Segunda fila: Alertas + Leads recientes -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Alertas -->
      <div class="lg:col-span-1">
        <h2 class="text-sm font-semibold text-slate-300 uppercase tracking-wide mb-3">Alertas activas</h2>
        <div class="card p-4">
          <AlertsPanel />
        </div>
      </div>

      <!-- Leads recientes -->
      <div class="lg:col-span-2">
        <h2 class="text-sm font-semibold text-slate-300 uppercase tracking-wide mb-3">Leads recientes</h2>
        <div class="card p-4">
          <RecentLeadsList :leads="recentLeads" />
        </div>
      </div>
    </div>
  </div>
</template>
