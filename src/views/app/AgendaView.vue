<script setup>
import { onMounted, ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { gsap } from 'gsap'
import { storeToRefs } from 'pinia'
import { useAgendaStore } from '@/stores/agenda'
import CalendarView from '@/components/agenda/CalendarView.vue'
import VisitaForm from '@/components/agenda/VisitaForm.vue'

const router = useRouter()
const store  = useAgendaStore()
const { visits, loading } = storeToRefs(store)

const currentDate = ref(new Date())
const showVisitForm = ref(false)
const selectedVisit = ref(null)
const navigating = ref(false)

function getRange(date) {
  const d = new Date(date)
  const start = new Date(d.getFullYear(), d.getMonth(), 1)
  const end   = new Date(d.getFullYear(), d.getMonth() + 1, 0, 23, 59, 59)
  return { from: start.toISOString(), to: end.toISOString() }
}

async function navigateMonth(delta) {
  if (navigating.value) return
  navigating.value = true
  currentDate.value = new Date(currentDate.value.getFullYear(), currentDate.value.getMonth() + delta, 1)
  const { from, to } = getRange(currentDate.value)
  await store.fetchByRange(from, to)
  navigating.value = false
}

onMounted(async () => {
  const { from, to } = getRange(currentDate.value)
  await store.fetchByRange(from, to)
  gsap.from('.animate-in', { opacity: 0, y: 10, stagger: 0.07, duration: 0.3 })
})

function prevMonth() { navigateMonth(-1) }
function nextMonth() { navigateMonth(1) }
function goToday() {
  if (navigating.value) return
  navigating.value = true
  currentDate.value = new Date()
  const { from, to } = getRange(currentDate.value)
  store.fetchByRange(from, to).then(() => { navigating.value = false })
}

function openVisit(visit) {
  router.push(`/app/visitas/${visit.id}`)
}
</script>

<template>
  <div class="p-6 space-y-4">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-white">📅 Agenda</h1>
        <p class="text-slate-400 text-sm">Calendario de visitas</p>
      </div>
      <button class="btn-primary" @click="showVisitForm = true; selectedVisit = null">
        + Nueva visita
      </button>
    </div>

    <CalendarView
      :visits="visits"
      :current-date="currentDate"
      @visit-click="openVisit"
      @prev="prevMonth"
      @next="nextMonth"
      @today="goToday"
    />

    <!-- Lista de visitas del mes -->
    <div class="card p-4 animate-in">
      <h3 class="text-sm font-semibold text-slate-300 mb-3">
        Visitas de {{ currentDate.toLocaleDateString('es-CL', { month: 'long', year: 'numeric' }) }}
      </h3>
      <div v-if="loading" class="text-center py-4 text-slate-500">Cargando...</div>
      <div v-else-if="!visits.length" class="text-center py-6 text-slate-500 text-sm">
        Sin visitas este mes
      </div>
      <div v-else class="space-y-2">
        <div v-for="visit in visits" :key="visit.id"
          class="flex items-center justify-between p-3 rounded-lg bg-slate-800/40 border border-slate-700/40 hover:border-slate-600 cursor-pointer transition-colors"
          @click="openVisit(visit)">
          <div class="flex items-center gap-3">
            <span class="text-lg">📅</span>
            <div>
              <p class="text-sm font-medium text-slate-200">{{ visit.animal?.name || '—' }}</p>
              <p class="text-xs text-slate-500">{{ new Date(visit.scheduled_at).toLocaleString('es-CL') }}</p>
            </div>
          </div>
          <div class="flex items-center gap-3">
            <span class="badge" :class="{
              'bg-blue-500/20 text-blue-400':   visit.status === 'scheduled',
              'bg-teal-500/20 text-teal-400':  visit.status === 'confirmed',
              'bg-amber-500/20 text-amber-400': visit.status === 'in_progress',
              'bg-brand-500/20 text-brand-400':  visit.status === 'completed',
              'bg-slate-500/20 text-slate-400': visit.status === 'cancelled',
            }">{{ visit.status }}</span>
            <span class="text-sm text-slate-600">→</span>
          </div>
        </div>
      </div>
    </div>

    <VisitaForm
      :show="showVisitForm"
      :visit="selectedVisit"
      @close="showVisitForm = false"
      @saved="() => { const { from, to } = getRange(currentDate.value); store.fetchByRange(from, to) }"
    />
  </div>
</template>
