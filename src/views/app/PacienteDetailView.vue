<script setup>
import { onMounted, ref } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import { gsap } from 'gsap'
import { patientsService } from '@/services/patients.service'
import ClinicalTimelineItem from '@/components/clinical/ClinicalTimelineItem.vue'
import { useToast } from '@/composables/useToast'

const route = useRoute()
const { addToast } = useToast()
const animal  = ref(null)
const loading = ref(true)

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
  const now    = new Date()
  const years  = now.getFullYear() - birth.getFullYear()
  const months = now.getMonth() - birth.getMonth()
  if (years < 1) return `${months} meses`
  return `${years} año${years > 1 ? 's' : ''}`
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
        <!-- Info -->
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
            <div v-if="animal.weight_kg" class="flex justify-between">
              <span class="text-slate-500">Peso</span>
              <span class="text-slate-300">{{ animal.weight_kg }} kg</span>
            </div>
            <div v-if="animal.notes" class="pt-2 border-t border-slate-700">
              <p class="text-slate-500 text-xs mb-1">Notas</p>
              <p class="text-slate-300 text-xs">{{ animal.notes }}</p>
            </div>
          </div>
        </div>

        <!-- Owner -->
        <div class="card p-4 animate-in">
          <h3 class="text-sm font-semibold text-slate-300 mb-3">Propietario</h3>
          <div class="space-y-2 text-sm">
            <div class="flex justify-between">
              <span class="text-slate-500">Nombre</span>
              <span class="text-slate-300">{{ animal.client?.name || '—' }}</span>
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

        <!-- Historial clínico -->
        <div class="lg:col-span-1 card p-4 animate-in">
          <h3 class="text-sm font-semibold text-slate-300 mb-3">Historial clínico</h3>
          <div v-if="animal.clinical_records?.length" class="space-y-4">
            <ClinicalTimelineItem v-for="rec in animal.clinical_records" :key="rec.id" :record="rec" />
          </div>
          <p v-else class="text-center py-4 text-slate-500 text-sm">Sin fichas clínicas</p>
        </div>
      </div>
    </template>
    <div v-else class="text-center py-12 text-slate-500">Paciente no encontrado</div>
  </div>
</template>
