<script setup>
import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useInventoryStore } from '@/stores/inventory'
import { useLeadsStore } from '@/stores/leads'
import { useAgendaStore } from '@/stores/agenda'

const inventoryStore = useInventoryStore()
const leadsStore     = useLeadsStore()
const agendaStore    = useAgendaStore()
const { lowStockItems } = storeToRefs(inventoryStore)
const { items: allLeads } = storeToRefs(leadsStore)
const { visits } = storeToRefs(agendaStore)

const now = new Date()
const twoHoursAgo = new Date(now - 2 * 60 * 60 * 1000)

const staleLeads = computed(() =>
  allLeads.value.filter(l => l.status === 'waiting' && new Date(l.created_at) < twoHoursAgo)
)

const upcomingVisits = computed(() => {
  const in24h = new Date(now.getTime() + 24 * 60 * 60 * 1000)
  return visits.value.filter(v =>
    new Date(v.scheduled_at) >= now && new Date(v.scheduled_at) <= in24h
  )
})
</script>

<template>
  <div v-if="lowStockItems.length || staleLeads.length || upcomingVisits.length"
    class="space-y-3">
    <!-- Stock crítico -->
    <div v-for="item in lowStockItems" :key="item.id"
      class="flex items-start gap-3 p-3 rounded-lg bg-red-500/10 border border-red-500/20">
      <span class="text-red-400 text-sm">⚠️</span>
      <div>
        <p class="text-sm font-medium text-red-300">Stock crítico</p>
        <p class="text-xs" style="color: var(--text-muted);">{{ item.name }} — {{ item.stock }} {{ item.unit }} (mín: {{ item.min_stock }})</p>
      </div>
    </div>

    <!-- Leads sin respuesta -->
    <div v-for="lead in staleLeads" :key="lead.id"
      class="flex items-start gap-3 p-3 rounded-lg bg-amber-500/10 border border-amber-500/20">
      <span class="text-amber-400 text-sm">⏰</span>
      <div>
        <p class="text-sm font-medium text-amber-300">Lead sin respuesta</p>
        <p class="text-xs" style="color: var(--text-muted);">{{ lead.client?.name }} — {{ lead.service_type }}</p>
      </div>
    </div>

    <!-- Visitas próximas -->
    <div v-for="visit in upcomingVisits" :key="visit.id"
      class="flex items-start gap-3 p-3 rounded-lg bg-blue-500/10 border border-blue-500/20">
      <span class="text-blue-400 text-sm">📅</span>
      <div>
        <p class="text-sm font-medium text-blue-300">Visita en 24h</p>
        <p class="text-xs" style="color: var(--text-muted);">{{ visit.animal?.name }} — {{ new Date(visit.scheduled_at).toLocaleString('es-CL') }}</p>
      </div>
    </div>
  </div>
  <div v-else class="text-center py-4 text-sm" style="color: var(--text-muted);">
    Sin alertas activas
  </div>
</template>
