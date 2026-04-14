<script setup>
import { onMounted, ref, computed } from 'vue'
import { gsap } from 'gsap'
import { leadsService } from '@/services/leads.service'
import { visitsService } from '@/services/visits.service'
import { LEAD_STATUS_LABELS } from '@/utils/constants'

const leads    = ref([])
const visits   = ref([])
const loading  = ref(true)
const period   = ref('7d')

const now = new Date()
const periods = {
  '1d':  new Date(now - 1 * 24 * 60 * 60 * 1000),
  '7d':  new Date(now - 7 * 24 * 60 * 60 * 1000),
  '30d': new Date(now - 30 * 24 * 60 * 60 * 1000),
}

const periodLeads = computed(() =>
  leads.value.filter(l => new Date(l.created_at) >= periods[period.value])
)
const periodVisits = computed(() =>
  visits.value.filter(v => new Date(v.scheduled_at) >= periods[period.value])
)
const totalLeads = computed(() => periodLeads.value.length)
const doneLeads  = computed(() => periodLeads.value.filter(l => l.status === 'done').length)
const conversion = computed(() => totalLeads.value ? Math.round((doneLeads.value / totalLeads.value) * 100) : 0)
const completedVisits = computed(() => periodVisits.value.filter(v => v.status === 'completed').length)

// Leads por estado
const byStatus = computed(() => {
  const map = {}
  Object.keys(LEAD_STATUS_LABELS).forEach(s => { map[s] = 0 })
  periodLeads.value.forEach(l => { if (map[l.status] !== undefined) map[l.status]++ })
  return map
})

// Servicios más solicitados
const byService = computed(() => {
  const map = {}
  periodLeads.value.forEach(l => {
    map[l.service_type] = (map[l.service_type] || 0) + 1
  })
  return Object.entries(map).sort((a, b) => b[1] - a[1]).slice(0, 5)
})

const maxStatus = computed(() => Math.max(...Object.values(byStatus.value), 1))

onMounted(async () => {
  try {
    const [leadsData, visitsData] = await Promise.all([
      leadsService.getAll(),
      visitsService.getByRange(
        periods['30d'].toISOString(),
        now.toISOString()
      ),
    ])
    leads.value  = leadsData
    visits.value = visitsData
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
  gsap.from('.animate-in', { opacity: 0, y: 10, stagger: 0.07, duration: 0.3 })
})
</script>

<template>
  <div class="p-6 space-y-5">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-white">📈 Reportes</h1>
        <p class="text-slate-400 text-sm">Métricas y estadísticas</p>
      </div>
      <!-- Selector período -->
      <div class="flex gap-1 bg-slate-800/60 rounded-lg p-1">
        <button v-for="p in [{v:'1d',l:'Hoy'},{v:'7d',l:'7D'},{v:'30d',l:'30D'}]" :key="p.v"
          @click="period = p.v"
          class="px-3 py-1.5 rounded-md text-xs font-medium transition-colors"
          :class="period === p.v ? 'bg-brand-600 text-white' : 'text-slate-400 hover:text-slate-200'">
          {{ p.l }}
        </button>
      </div>
    </div>

    <div v-if="loading" class="text-center py-12 text-slate-500">Cargando...</div>
    <template v-else>
      <!-- Métricas -->
      <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div class="card p-4 animate-in">
          <p class="text-slate-500 text-xs uppercase tracking-wide mb-1">Total Leads</p>
          <p class="text-2xl font-bold text-white">{{ totalLeads }}</p>
        </div>
        <div class="card p-4 animate-in">
          <p class="text-slate-500 text-xs uppercase tracking-wide mb-1">Tasa Conversión</p>
          <p class="text-2xl font-bold text-brand-400">{{ conversion }}%</p>
        </div>
        <div class="card p-4 animate-in">
          <p class="text-slate-500 text-xs uppercase tracking-wide mb-1">Visitas Completadas</p>
          <p class="text-2xl font-bold text-white">{{ completedVisits }}</p>
        </div>
        <div class="card p-4 animate-in">
          <p class="text-slate-500 text-xs uppercase tracking-wide mb-1">Leads Cerrados</p>
          <p class="text-2xl font-bold text-white">{{ doneLeads }}</p>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <!-- Leads por estado -->
        <div class="card p-4 animate-in">
          <h3 class="text-sm font-semibold text-slate-300 mb-4">Leads por estado</h3>
          <div class="space-y-3">
            <div v-for="(count, status) in byStatus" :key="status" class="flex items-center gap-3">
              <span class="text-xs text-slate-400 w-24 truncate">{{ LEAD_STATUS_LABELS[status] }}</span>
              <div class="flex-1 h-2 bg-slate-700 rounded-full overflow-hidden">
                <div class="h-full bg-brand-500 rounded-full transition-all duration-700"
                  :style="{ width: (count / maxStatus * 100) + '%' }" />
              </div>
              <span class="text-xs text-slate-400 w-6 text-right">{{ count }}</span>
            </div>
          </div>
        </div>

        <!-- Top servicios -->
        <div class="card p-4 animate-in">
          <h3 class="text-sm font-semibold text-slate-300 mb-4">Servicios más solicitados</h3>
          <div class="space-y-2">
            <div v-for="([service, count], i) in byService" :key="service"
              class="flex items-center justify-between p-2 rounded-lg bg-slate-800/40">
              <div class="flex items-center gap-3">
                <span class="text-xs text-slate-600 w-4">#{{ i + 1 }}</span>
                <span class="text-sm text-slate-300 capitalize">{{ service.replace('_',' ') }}</span>
              </div>
              <span class="badge bg-brand-500/20 text-brand-400">{{ count }}</span>
            </div>
            <p v-if="!byService.length" class="text-center py-4 text-slate-500 text-sm">Sin datos</p>
          </div>
        </div>
      </div>

      <!-- Detalle tabular -->
      <div class="card p-4 animate-in overflow-x-auto">
        <h3 class="text-sm font-semibold text-slate-300 mb-3">Detalle de leads del período</h3>
        <table class="w-full text-sm">
          <thead>
            <tr class="text-slate-500 text-xs border-b border-slate-700">
              <th class="text-left py-2 px-2">Fecha</th>
              <th class="text-left py-2 px-2">Cliente</th>
              <th class="text-left py-2 px-2">Servicio</th>
              <th class="text-left py-2 px-2">Estado</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="lead in periodLeads.slice(0, 20)" :key="lead.id"
              class="border-b border-slate-800 hover:bg-slate-800/40">
              <td class="py-2 px-2 text-slate-400">{{ new Date(lead.created_at).toLocaleDateString('es-CL') }}</td>
              <td class="py-2 px-2 text-slate-300">{{ lead.client?.name || '—' }}</td>
              <td class="py-2 px-2 text-slate-300 capitalize">{{ lead.service_type?.replace('_',' ') }}</td>
              <td class="py-2 px-2">
                <span class="badge text-xs" :class="{
                  'bg-amber-500/20 text-amber-400': lead.status === 'waiting',
                  'bg-blue-500/20 text-blue-400':   lead.status === 'in_progress',
                  'bg-brand-500/20 text-brand-400': lead.status === 'done',
                  'bg-slate-500/20 text-slate-400': lead.status === 'cancelled',
                }">{{ lead.status }}</span>
              </td>
            </tr>
          </tbody>
        </table>
        <p v-if="!periodLeads.length" class="text-center py-4 text-slate-500 text-sm">Sin leads en este período</p>
      </div>
    </template>
  </div>
</template>
