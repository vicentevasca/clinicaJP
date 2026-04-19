<script setup>
import { onMounted, ref, computed } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import { gsap } from 'gsap'
import { patientsService } from '@/services/patients.service'
import ClinicalTimelineItem from '@/components/clinical/ClinicalTimelineItem.vue'
import VaccinationHistory from '@/components/clinical/VaccinationHistory.vue'
import { useToast } from '@/composables/useToast'
import { formatRUT } from '@/utils/validators'

const route = useRoute()
const { addToast } = useToast()
const animal  = ref(null)
const loading = ref(true)
const activeTab = ref('historial')

const TABS = [
  { key: 'historial', label: 'Historial clínico' },
  { key: 'vacunas',   label: 'Vacunas' },
  { key: 'peso',      label: 'Evolución de peso' },
]

const speciesEmoji = {
  perro: '🐕', gato: '🐈', ave: '🐦', gallina: '🐔', caballo: '🐴', bovino: '🐄', otro: '🐾'
}

onMounted(async () => {
  try {
    animal.value = await patientsService.getAnimalById(route.params.id)
  } catch (e) {
    addToast('Error: ' + e.message, 'error')
  } finally {
    loading.value = false
  }
  gsap.from('.animate-in', { opacity: 0, y: 10, stagger: 0.07, duration: 0.3 })
})

function calcAge(birthDate) {
  if (!birthDate) return '—'
  const birth = new Date(birthDate)
  const now   = new Date()
  const years  = now.getFullYear() - birth.getFullYear()
  const months = now.getMonth() - birth.getMonth()
  if (years < 1) return `${months} meses`
  return `${years} año${years > 1 ? 's' : ''}`
}

// Registros con peso, ordenados de más viejo a más reciente para el gráfico
const weightHistory = computed(() => {
  if (!animal.value?.clinical_records) return []
  return [...animal.value.clinical_records]
    .filter(r => r.weight_kg)
    .sort((a, b) => new Date(a.created_at) - new Date(b.created_at))
})

const maxWeight = computed(() =>
  weightHistory.value.length
    ? Math.max(...weightHistory.value.map(r => r.weight_kg))
    : 0
)

function barHeight(kg) {
  if (!maxWeight.value) return 0
  return Math.round((kg / (maxWeight.value * 1.2)) * 100)
}

function formatDate(d) {
  return new Date(d).toLocaleDateString('es-CL', { day: '2-digit', month: 'short' })
}
</script>

<template>
  <div class="p-6 space-y-5">
    <RouterLink to="/app/pacientes" class="btn-ghost text-sm">← Volver a pacientes</RouterLink>

    <div v-if="loading" class="text-center py-12 text-slate-500">Cargando...</div>
    <template v-else-if="animal">
      <!-- Header -->
      <div class="flex items-center gap-4 animate-in">
        <div class="w-16 h-16 rounded-full bg-slate-700/60 flex items-center justify-center text-3xl">
          {{ speciesEmoji[animal.species] || '🐾' }}
        </div>
        <div>
          <h1 class="text-xl font-bold text-white">{{ animal.name }}</h1>
          <p class="text-slate-400 capitalize">{{ animal.breed || animal.species }} · {{ animal.sex || '' }}</p>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">
        <!-- Datos del paciente -->
        <div class="card p-4 animate-in">
          <h3 class="text-sm font-semibold text-slate-300 mb-3">Datos del paciente</h3>
          <div class="space-y-2 text-sm">
            <div class="flex justify-between">
              <span class="text-slate-500">Especie</span>
              <span class="text-slate-300 capitalize">{{ animal.species }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500">Raza</span>
              <span class="text-slate-300 capitalize">{{ animal.breed || '—' }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500">Sexo</span>
              <span class="text-slate-300 capitalize">{{ animal.sex || '—' }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500">Edad</span>
              <span class="text-slate-300">{{ calcAge(animal.birth_date) }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500">Peso actual</span>
              <span class="text-slate-300 font-medium">
                {{ animal.weight_kg ? animal.weight_kg + ' kg' : '—' }}
              </span>
            </div>
            <div v-if="animal.notes" class="pt-2 border-t border-slate-700">
              <p class="text-slate-500 text-xs mb-1">Notas</p>
              <p class="text-slate-300 text-xs">{{ animal.notes }}</p>
            </div>
          </div>
        </div>

        <!-- Propietario -->
        <div class="card p-4 animate-in">
          <h3 class="text-sm font-semibold text-slate-300 mb-3">Propietario</h3>
          <div class="space-y-2 text-sm">
            <div class="flex justify-between">
              <span class="text-slate-500">Nombre</span>
              <span class="text-slate-300">{{ animal.client?.name || '—' }}</span>
            </div>
            <div v-if="animal.client?.rut" class="flex justify-between">
              <span class="text-slate-500">RUT</span>
              <span class="text-slate-300">{{ formatRUT(animal.client.rut) }}</span>
            </div>
            <div v-if="animal.client?.phone" class="flex justify-between">
              <span class="text-slate-500">Teléfono</span>
              <a :href="`tel:${animal.client.phone}`" class="text-brand-400 hover:underline">
                {{ animal.client.phone }}
              </a>
            </div>
            <div v-if="animal.client?.email" class="flex justify-between">
              <span class="text-slate-500">Email</span>
              <span class="text-slate-300">{{ animal.client.email }}</span>
            </div>
            <div v-if="animal.client?.address" class="pt-2 border-t border-slate-700">
              <p class="text-slate-500 text-xs mb-1">Dirección</p>
              <p class="text-slate-300 text-xs">{{ animal.client.address }}</p>
            </div>
          </div>
          <a v-if="animal.client?.phone"
            :href="`https://wa.me/${animal.client.phone.replace(/\D/g,'')}`"
            target="_blank" class="btn-primary w-full mt-3 text-center text-sm">
            💬 WhatsApp
          </a>
        </div>

        <!-- Panel de pestañas: historial / vacunas / peso -->
        <div class="lg:col-span-1 card p-4 animate-in">
          <!-- Tabs -->
          <div class="flex border-b border-slate-700 mb-4 -mx-1">
            <button v-for="tab in TABS" :key="tab.key"
              @click="activeTab = tab.key"
              class="px-3 py-1.5 text-xs font-medium transition-colors border-b-2 -mb-px"
              :class="activeTab === tab.key
                ? 'border-brand-500 text-brand-400'
                : 'border-transparent text-slate-500 hover:text-slate-300'">
              {{ tab.label }}
            </button>
          </div>

          <!-- Historial clínico -->
          <div v-if="activeTab === 'historial'">
            <div v-if="animal.clinical_records?.length" class="space-y-4">
              <ClinicalTimelineItem
                v-for="rec in [...(animal.clinical_records)].sort((a,b) => new Date(b.created_at) - new Date(a.created_at))"
                :key="rec.id"
                :record="rec"
              />
            </div>
            <p v-else class="text-center py-4 text-slate-500 text-sm">Sin fichas clínicas</p>
          </div>

          <!-- Vacunas -->
          <div v-if="activeTab === 'vacunas'">
            <VaccinationHistory :animal-id="animal.id" />
          </div>

          <!-- Evolución de peso -->
          <div v-if="activeTab === 'peso'">
            <div v-if="!weightHistory.length"
              class="text-center py-4 text-slate-500 text-sm">
              Sin registros de peso
            </div>
            <div v-else>
              <!-- Mini gráfico de barras -->
              <div class="flex items-end gap-1 h-24 mb-3">
                <div v-for="rec in weightHistory" :key="rec.id"
                  class="flex-1 flex flex-col items-center gap-1 group relative">
                  <div class="absolute -top-5 left-1/2 -translate-x-1/2 opacity-0 group-hover:opacity-100
                    bg-slate-800 text-white text-xs px-1.5 py-0.5 rounded pointer-events-none transition-opacity whitespace-nowrap z-10">
                    {{ rec.weight_kg }} kg
                  </div>
                  <div class="w-full bg-brand-500/70 rounded-t transition-all duration-300"
                    :style="{ height: barHeight(rec.weight_kg) + '%' }" />
                </div>
              </div>
              <!-- Tabla -->
              <div class="space-y-1.5">
                <div v-for="rec in [...weightHistory].reverse()" :key="rec.id"
                  class="flex justify-between items-center text-xs">
                  <span class="text-slate-500">{{ formatDate(rec.created_at) }}</span>
                  <span class="font-medium text-slate-300">{{ rec.weight_kg }} kg</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
    <div v-else class="text-center py-12 text-slate-500">Paciente no encontrado</div>
  </div>
</template>
