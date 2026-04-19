<script setup>
import { onMounted, ref } from 'vue'
import { useRoute, useRouter, RouterLink } from 'vue-router'
import { gsap } from 'gsap'
import { leadsService } from '@/services/leads.service'
import { visitsService } from '@/services/visits.service'
import { useLeadsStore } from '@/stores/leads'
import { useToast } from '@/composables/useToast'
import LeadStatusBadge from '@/components/leads/LeadStatusBadge.vue'
import LeadTimeline from '@/components/leads/LeadTimeline.vue'
import WhatsAppPreview from '@/components/leads/WhatsAppPreview.vue'
import VisitaSummaryCard from '@/components/visits/VisitaSummaryCard.vue'
import { LEAD_STATUS, LEAD_STATUS_LABELS, PRIORITY_LEVELS, SERVICE_TYPES, VISIT_STATUS_LABELS } from '@/utils/constants'
import { formatRUT } from '@/utils/validators'

const serviceLabel = (val) => SERVICE_TYPES.find(s => s.value === val)?.label ?? val
const priorityLabel = (val) => PRIORITY_LEVELS.find(p => p.value === val)?.label ?? val

const route    = useRoute()
const router   = useRouter()
const store    = useLeadsStore()
const { addToast } = useToast()

const lead     = ref(null)
const history  = ref([])
const visit    = ref(null)
const loading  = ref(true)

const priorityColor = {
  low: 'text-slate-400', normal: 'text-blue-400', high: 'text-amber-400', urgent: 'text-red-400'
}

onMounted(async () => {
  try {
    const id = route.params.id
    lead.value = await leadsService.getById(id)
    history.value = await leadsService.getHistory(id)
    visit.value = await visitsService.getByLeadId(id)
  } catch (e) {
    addToast('Error cargando lead: ' + e.message, 'error')
  } finally {
    loading.value = false
  }
  gsap.from('.animate-in', { opacity: 0, y: 10, stagger: 0.07, duration: 0.3 })
})

async function changeStatus(newStatus) {
  try {
    await store.updateStatus(lead.value.id, newStatus)
    lead.value.status = newStatus
    addToast('Estado actualizado', 'success')
    history.value = await leadsService.getHistory(lead.value.id)
  } catch (e) {
    addToast('Error: ' + e.message, 'error')
  }
}
</script>

<template>
  <div class="p-6 space-y-5">
    <!-- Back -->
    <RouterLink to="/app/leads" class="btn-ghost text-sm">← Volver a leads</RouterLink>

    <div v-if="loading" class="text-center py-12 text-slate-500">Cargando...</div>
    <template v-else-if="lead">
      <!-- Header -->
      <div class="flex items-start justify-between animate-in">
        <div class="flex items-center gap-4">
          <span class="text-4xl">
            {{ { perro:'🐕', gato:'🐈', ave:'🐦', gallina:'🐔', caballo:'🐴', bovino:'🐄', otro:'🐾' }[lead.animal?.species] || '🐾' }}
          </span>
          <div>
            <h1 class="text-xl font-bold text-white">{{ lead.client?.name || 'Sin nombre' }}</h1>
            <p class="text-slate-400 text-sm">{{ lead.animal?.name }} · {{ serviceLabel(lead.service_type) }}</p>
          </div>
        </div>
        <div class="flex gap-2 flex-wrap">
          <LeadStatusBadge :status="lead.status" />
          <span class="badge" :class="lead.priority === 'urgent' ? 'bg-red-500/20 text-red-400' : 'bg-slate-500/20 text-slate-400'">
            {{ priorityLabel(lead.priority) }}
          </span>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">
        <!-- Info grid -->
        <div class="lg:col-span-2 space-y-4">
          <!-- Info -->
          <div class="card p-4 animate-in">
            <h3 class="text-sm font-semibold text-slate-300 mb-3">Información</h3>
            <div class="grid grid-cols-2 gap-3 text-sm">
              <div v-if="lead.client?.rut">
                <p class="text-slate-500 text-xs">RUT</p>
                <p class="text-slate-300">{{ formatRUT(lead.client.rut) }}</p>
              </div>
              <div>
                <p class="text-slate-500 text-xs">Teléfono</p>
                <a v-if="lead.client?.phone" :href="`tel:${lead.client.phone}`"
                  class="text-brand-400 hover:underline">{{ lead.client.phone }}</a>
                <p v-else class="text-slate-400">—</p>
              </div>
              <div>
                <p class="text-slate-500 text-xs">Email</p>
                <p class="text-slate-300">{{ lead.client?.email || '—' }}</p>
              </div>
              <div>
                <p class="text-slate-500 text-xs">Ubicación</p>
                <p class="text-slate-300">{{ [lead.client?.comuna, lead.client?.region].filter(Boolean).join(', ') || '—' }}</p>
              </div>
              <div>
                <p class="text-slate-500 text-xs">Dirección</p>
                <p class="text-slate-300">{{ lead.client?.address || '—' }}</p>
              </div>
              <div>
                <p class="text-slate-500 text-xs">Servicio</p>
                <p class="text-slate-300">{{ serviceLabel(lead.service_type) }}</p>
              </div>
              <div>
                <p class="text-slate-500 text-xs">Recibido</p>
                <p class="text-slate-300">{{ new Date(lead.created_at).toLocaleString('es-CL') }}</p>
              </div>
              <div class="col-span-2">
                <p class="text-slate-500 text-xs">Descripción</p>
                <p class="text-slate-300">{{ lead.description || '—' }}</p>
              </div>
            </div>
          </div>

          <!-- Timeline -->
          <div class="card p-4 animate-in">
            <h3 class="text-sm font-semibold text-slate-300 mb-3">Historial</h3>
            <LeadTimeline :history="history" />
          </div>
        </div>

        <!-- Sidebar -->
        <div class="space-y-4">
          <!-- Acciones -->
          <div class="card p-4 space-y-2 animate-in">
            <h3 class="text-sm font-semibold text-slate-300 mb-2">Acciones</h3>

            <a v-if="lead.client?.phone" :href="`https://wa.me/${lead.client.phone.replace(/\D/g,'')}`"
              target="_blank" class="btn-primary w-full text-center">
              💬 WhatsApp
            </a>

            <button v-if="lead.status === 'waiting'"
              @click="changeStatus('in_progress')"
              class="btn-primary w-full">
              🔄 Marcar en curso
            </button>
            <button v-if="lead.status === 'in_progress'"
              @click="changeStatus('done')"
              class="btn-primary w-full">
              ✅ Marcar como cerrado
            </button>
            <button v-if="lead.status !== 'cancelled' && lead.status !== 'done'"
              @click="changeStatus('cancelled')"
              class="btn-secondary w-full text-red-400 hover:bg-red-500/20">
              ❌ Cancelar
            </button>
          </div>

          <!-- WhatsApp preview -->
          <WhatsAppPreview :lead="lead" />

          <!-- Visita -->
          <VisitaSummaryCard :visit="visit" />
        </div>
      </div>
    </template>
    <div v-else class="text-center py-12 text-slate-500">Lead no encontrado</div>
  </div>
</template>
