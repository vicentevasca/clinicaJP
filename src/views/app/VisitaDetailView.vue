<script setup>
import { onMounted, ref, computed } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import { gsap } from 'gsap'
import { visitsService } from '@/services/visits.service'
import { useToast } from '@/composables/useToast'
import { VISIT_STATUS_LABELS } from '@/utils/constants'
import FichaClinica from '@/components/clinical/FichaClinica.vue'
import FichaForm from '@/components/clinical/FichaForm.vue'
import VaccinationForm from '@/components/clinical/VaccinationForm.vue'

const route    = useRoute()
const { addToast } = useToast()
const visit    = ref(null)
const loading  = ref(true)
const showVaccinationForm = ref(false)
const vaccinationsSaved   = ref(false)

const statusColor = {
  scheduled:   'bg-blue-500/20 text-blue-400 border-blue-500/30',
  confirmed:   'bg-teal-500/20 text-teal-400 border-teal-500/30',
  in_progress: 'bg-amber-500/20 text-amber-400 border-amber-500/30',
  completed:   'bg-brand-500/20 text-brand-400 border-brand-500/30',
  cancelled:   'bg-slate-500/20 text-slate-400 border-slate-500/30',
}

onMounted(async () => {
  try {
    visit.value = await visitsService.getById(route.params.id)
    // Si ya hay ficha guardada, mostrar form de vacunas por defecto al retomar
    if (visit.value?.clinical_records?.[0]) {
      showVaccinationForm.value = true
    }
  } catch (e) {
    addToast('Error: ' + e.message, 'error')
  } finally {
    loading.value = false
  }
  gsap.from('.animate-in', { opacity: 0, y: 10, stagger: 0.07, duration: 0.3 })
})

// La ficha está guardada cuando hay al menos un clinical_record
const hasFicha = computed(() => !!visit.value?.clinical_records?.[0])

// Solo se puede cerrar si la ficha fue guardada
const canClose = computed(() =>
  visit.value?.status === 'in_progress' && hasFicha.value
)

async function changeStatus(newStatus) {
  if (newStatus === 'completed' && !canClose.value) {
    addToast('Guardá la ficha clínica antes de cerrar la visita', 'warning')
    return
  }
  try {
    await visitsService.updateStatus(visit.value.id, newStatus)
    visit.value.status = newStatus
    addToast('Estado actualizado', 'success')
  } catch (e) {
    addToast('Error: ' + e.message, 'error')
  }
}

async function onFichaSaved() {
  visit.value = await visitsService.getById(visit.value.id)
  showVaccinationForm.value = true
}

function onVaccinationsSaved() {
  vaccinationsSaved.value = true
  addToast('Vacunas registradas correctamente', 'success')
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
          <h1 class="text-xl font-bold text-white">
            📅 {{ new Date(visit.scheduled_at).toLocaleDateString('es-CL') }}
          </h1>
          <p class="text-slate-400 text-sm">
            {{ new Date(visit.scheduled_at).toLocaleTimeString('es-CL', { hour: '2-digit', minute: '2-digit' }) }}
            · {{ visit.duration_min }} min
          </p>
        </div>
        <span class="badge border" :class="statusColor[visit.status]">
          {{ VISIT_STATUS_LABELS[visit.status] || visit.status }}
        </span>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">
        <!-- Información -->
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

            <!-- Cerrar — solo habilitado si hay ficha guardada -->
            <div v-if="visit.status === 'in_progress'" class="space-y-1">
              <button
                @click="changeStatus('completed')"
                :disabled="!canClose"
                class="btn-primary w-full disabled:opacity-40 disabled:cursor-not-allowed">
                ✅ Cerrar visita
              </button>
              <p v-if="!canClose" class="text-xs text-amber-400 text-center">
                Guardá la ficha clínica primero
              </p>
            </div>

            <button v-if="visit.status !== 'cancelled' && visit.status !== 'completed'"
              @click="changeStatus('cancelled')"
              class="btn-secondary w-full text-red-400 hover:bg-red-500/20">
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

        <!-- Panel derecho: ficha + vacunas -->
        <div class="lg:col-span-1 space-y-4">
          <!-- Ficha clínica -->
          <FichaForm
            v-if="visit.status === 'in_progress' || visit.status === 'completed'"
            :visit-id="visit.id"
            :animal-id="visit.animal_id"
            :existing="visit.clinical_records?.[0]"
            @saved="onFichaSaved"
          />
          <FichaClinica v-else :record="visit.clinical_records?.[0]" />

          <!-- Vacunas: mostrar si visita en progreso/completada y la ficha ya fue guardada -->
          <div v-if="(visit.status === 'in_progress' || visit.status === 'completed') && hasFicha">
            <div v-if="!showVaccinationForm"
              class="card p-4 text-center">
              <p class="text-sm text-slate-400 mb-3">¿Se aplicaron vacunas en esta visita?</p>
              <button class="btn-secondary text-sm" @click="showVaccinationForm = true">
                💉 Registrar vacunas
              </button>
            </div>
            <VaccinationForm
              v-else
              :visit-id="visit.id"
              :animal-id="visit.animal_id"
              @saved="onVaccinationsSaved"
            />
          </div>
        </div>
      </div>
    </template>
    <div v-else class="text-center py-12 text-slate-500">Visita no encontrada</div>
  </div>
</template>
