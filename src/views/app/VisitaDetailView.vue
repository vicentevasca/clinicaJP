<script setup>
import { onMounted, ref } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import { gsap } from 'gsap'
import { visitsService } from '@/services/visits.service'
import { useToast } from '@/composables/useToast'
import { VISIT_STATUS_LABELS } from '@/utils/constants'
import FichaClinica from '@/components/clinical/FichaClinica.vue'
import FichaForm from '@/components/clinical/FichaForm.vue'

const route    = useRoute()
const { addToast } = useToast()
const visit    = ref(null)
const loading  = ref(true)

const statusColor = {
  scheduled:  'bg-blue-500/20 text-blue-400 border-blue-500/30',
  confirmed:  'bg-teal-500/20 text-teal-400 border-teal-500/30',
  in_progress:'bg-amber-500/20 text-amber-400 border-amber-500/30',
  completed:  'bg-brand-500/20 text-brand-400 border-brand-500/30',
  cancelled:  'bg-slate-500/20 text-slate-400 border-slate-500/30',
}

onMounted(async () => {
  try {
    visit.value = await visitsService.getById(route.params.id)
  } catch (e) {
    addToast('Error: ' + e.message, 'error')
  } finally {
    loading.value = false
  }
  gsap.from('.animate-in', { opacity: 0, y: 10, stagger: 0.07, duration: 0.3 })
})

async function changeStatus(newStatus) {
  try {
    await visitsService.updateStatus(visit.value.id, newStatus)
    visit.value.status = newStatus
    addToast('Estado actualizado', 'success')
  } catch (e) {
    addToast('Error: ' + e.message, 'error')
  }
}

function onFichaSaved() {
  // Refrescar visita
  visitsService.getById(visit.value.id).then(v => { visit.value = v })
}
</script>

<template>
  <div class="p-6 space-y-5">
    <RouterLink to="/app/agenda" class="btn-ghost text-sm">← Volver a agenda</RouterLink>

    <div v-if="loading" class="text-center py-12 text-slate-500">Cargando...</div>
    <template v-else-if="visit">
      <!-- Header -->
      <div class="flex items-start justify-between animate-in">
        <div>
          <h1 class="text-xl font-bold text-white">📅 {{ new Date(visit.scheduled_at).toLocaleDateString('es-CL') }}</h1>
          <p class="text-slate-400 text-sm">
            {{ new Date(visit.scheduled_at).toLocaleTimeString('es-CL', {hour:'2-digit',minute:'2-digit'}) }}
            · {{ visit.duration_min }} min
          </p>
        </div>
        <span class="badge border" :class="statusColor[visit.status]">{{ VISIT_STATUS_LABELS[visit.status] || visit.status }}</span>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">
        <!-- Info -->
        <div class="card p-4 animate-in">
          <h3 class="text-sm font-semibold text-slate-300 mb-3">Información</h3>
          <div class="space-y-2 text-sm">
            <div class="flex justify-between">
              <span class="text-slate-500">Cliente</span>
              <span class="text-slate-300">{{ visit.client?.name || '—' }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500">Teléfono</span>
              <a v-if="visit.client?.phone" :href="`tel:${visit.client.phone}`"
                class="text-brand-400 hover:underline">{{ visit.client.phone }}</a>
              <span v-else class="text-slate-400">—</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500">Animal</span>
              <span class="text-slate-300">{{ visit.animal?.name || '—' }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500">Técnico</span>
              <span class="text-slate-300">{{ visit.assigned?.name || '—' }}</span>
            </div>
            <div class="pt-2 border-t border-slate-700">
              <p class="text-slate-500 text-xs mb-1">Dirección</p>
              <p class="text-slate-300">{{ visit.address }}</p>
            </div>
            <div v-if="visit.notes" class="pt-2 border-t border-slate-700">
              <p class="text-slate-500 text-xs mb-1">Notas</p>
              <p class="text-slate-300 text-xs">{{ visit.notes }}</p>
            </div>
          </div>
        </div>

        <!-- Acciones -->
        <div class="space-y-4 animate-in">
          <!-- Status actions -->
          <div class="card p-4 space-y-2">
            <h3 class="text-sm font-semibold text-slate-300 mb-2">Cambiar estado</h3>
            <button v-if="visit.status === 'scheduled'"
              @click="changeStatus('confirmed')" class="btn-primary w-full">
              ✓ Confirmar
            </button>
            <button v-if="visit.status === 'confirmed'"
              @click="changeStatus('in_progress')" class="btn-primary w-full">
              🚀 Iniciar visita
            </button>
            <button v-if="visit.status === 'in_progress'"
              @click="changeStatus('completed')" class="btn-primary w-full">
              ✅ Cerrar visita
            </button>
            <button v-if="visit.status !== 'cancelled' && visit.status !== 'completed'"
              @click="changeStatus('cancelled')" class="btn-secondary w-full text-red-400 hover:bg-red-500/20">
              ❌ Cancelar
            </button>
          </div>

          <!-- WhatsApp cliente -->
          <a v-if="visit.client?.phone"
            :href="`https://wa.me/${visit.client.phone.replace(/\D/g,'')}`"
            target="_blank" class="btn-primary w-full text-center block">
            💬 WhatsApp cliente
          </a>
        </div>

        <!-- Ficha clínica -->
        <div class="lg:col-span-1">
          <FichaForm
            v-if="visit.status === 'in_progress' || visit.status === 'completed'"
            :visit-id="visit.id"
            :animal-id="visit.animal_id"
            :existing="visit.clinical_records?.[0]"
            @saved="onFichaSaved"
          />
          <FichaClinica v-else :record="visit.clinical_records?.[0]" />
        </div>
      </div>
    </template>
    <div v-else class="text-center py-12 text-slate-500">Visita no encontrada</div>
  </div>
</template>
