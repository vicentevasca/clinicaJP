<script setup>
import { computed } from 'vue'

const props = defineProps({
  visits:      { type: Array, default: () => [] },
  currentDate: { type: Date, default: () => new Date() },
  view:        { type: String, default: 'month' }, // month | week | day
})

defineEmits(['visit-click', 'new-visit'])

const DAYS_ES = ['Dom','Lun','Mar','Mié','Jue','Vie','Sáb']
const MONTHS_ES = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre']

const statusColor = {
  scheduled:  'border-l-2 border-blue-500',
  confirmed:  'border-l-2 border-teal-500',
  in_progress:'border-l-2 border-amber-500',
  completed:  'border-l-2 border-brand-500',
  cancelled:  'border-l-2 border-slate-500',
}

const visitsByDay = computed(() => {
  const map = {}
  props.visits.forEach(v => {
    const d = new Date(v.scheduled_at).toDateString()
    if (!map[d]) map[d] = []
    map[d].push(v)
  })
  return map
})

const calendarDays = computed(() => {
  const year  = props.currentDate.getFullYear()
  const month = props.currentDate.getMonth()
  const firstDay = new Date(year, month, 1)
  const lastDay  = new Date(year, month + 1, 0)
  const days = []
  // Pad start
  for (let i = 0; i < firstDay.getDay(); i++) {
    days.push(null)
  }
  // Days of month
  for (let d = 1; d <= lastDay.getDate(); d++) {
    days.push(new Date(year, month, d))
  }
  return days
})

function isToday(date) {
  if (!date) return false
  const t = new Date()
  return date.getDate() === t.getDate() && date.getMonth() === t.getMonth() && date.getFullYear() === t.getFullYear()
}
function dayKey(date) {
  return date?.toDateString() || ''
}
</script>

<template>
  <div class="card p-4">
    <!-- Header con navegación -->
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-sm font-semibold text-slate-300">
        {{ MONTHS_ES[currentDate.getMonth()] }} {{ currentDate.getFullYear() }}
      </h3>
      <div class="flex gap-1">
        <button @click="$emit('prev')" class="btn-ghost text-xs px-2 py-1">←</button>
        <button @click="$emit('today')" class="btn-ghost text-xs px-2 py-1">Hoy</button>
        <button @click="$emit('next')" class="btn-ghost text-xs px-2 py-1">→</button>
      </div>
    </div>

    <!-- Días de la semana -->
    <div class="grid grid-cols-7 mb-1">
      <div v-for="d in DAYS_ES" :key="d"
        class="text-center text-xs font-medium text-slate-500 py-1">
        {{ d }}
      </div>
    </div>

    <!-- Calendario -->
    <div class="grid grid-cols-7 gap-px bg-slate-700/30">
      <div v-for="(day, i) in calendarDays" :key="i"
        class="min-h-[80px] bg-slate-800/40 p-1 relative"
        :class="isToday(day) ? 'ring-1 ring-brand-500/50' : ''">
        <span v-if="day" class="text-xs font-medium"
          :class="isToday(day) ? 'text-brand-400' : 'text-slate-400'">
          {{ day.getDate() }}
        </span>
        <!-- Visits -->
        <div v-if="day && visitsByDay[dayKey(day)]?.length"
          class="mt-0.5 space-y-0.5">
          <div v-for="v in visitsByDay[dayKey(day)].slice(0,3)" :key="v.id"
            class="text-xs p-0.5 rounded bg-slate-700/60 truncate cursor-pointer hover:bg-slate-700"
            :class="statusColor[v.status]"
            @click="$emit('visit-click', v)">
            {{ new Date(v.scheduled_at).toLocaleTimeString('es-CL', {hour:'2-digit',minute:'2-digit'}) }}
            {{ v.animal?.name || '—' }}
          </div>
          <div v-if="visitsByDay[dayKey(day)].length > 3"
            class="text-xs text-slate-600 text-center">
            +{{ visitsByDay[dayKey(day)].length - 3 }} más
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
