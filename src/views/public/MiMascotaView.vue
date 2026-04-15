<script setup>
import { ref, onMounted } from 'vue'
import { gsap } from 'gsap'
import { clientsService } from '@/services/clients.service'
import { useToast } from '@/composables/useToast'
import ClientSearchForm from '@/components/public/ClientSearchForm.vue'
import ClientDashboard from '@/components/public/ClientDashboard.vue'

const toast = useToast()

const view = ref('search') // 'search' | 'dashboard'
const client = ref(null)
const animals = ref([])
const loading = ref(false)
const error = ref('')
const dashboardRef = ref(null)

async function handleSearch({ type, value }) {
  loading.value = true
  error.value = ''
  try {
    const data = type === 'rut'
      ? await clientsService.findByRut(value)
      : await clientsService.findByPhone(value)
    client.value = data.client
    animals.value = data.animals || []
    view.value = 'dashboard'
  } catch (e) {
    error.value = e.message === 'Cliente no encontrado'
      ? 'No encontramos ningún cliente con ese identificador'
      : 'Error al buscar. Intenta nuevamente.'
  } finally {
    loading.value = false
  }
}

function handleLogout() {
  view.value = 'search'
  client.value = null
  animals.value = []
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 pt-16">
    <!-- Public navbar -->
    <nav class="fixed top-0 left-0 right-0 z-50 bg-slate-900/80 backdrop-blur-md border-b border-slate-700/50">
      <div class="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
        <RouterLink to="/" class="flex items-center gap-2">
          <span class="text-2xl">🐾</span>
          <span class="text-lg font-bold text-white">VetDesk</span>
        </RouterLink>
        <div class="flex items-center gap-4">
          <RouterLink to="/solicitar" class="btn-primary text-sm">
            Solicitar visita
          </RouterLink>
        </div>
      </div>
    </nav>

    <!-- Content -->
    <div class="max-w-4xl mx-auto px-6 py-12">
      <!-- Search view -->
      <div v-if="view === 'search'" class="pt-8">
        <ClientSearchForm @search="handleSearch" />
        <p v-if="error" class="text-red-400 text-sm text-center mt-4">{{ error }}</p>
      </div>

      <!-- Dashboard view -->
      <div v-else ref="dashboardRef">
        <ClientDashboard
          v-if="client"
          :client="client"
          :animals="animals"
          @logout="handleLogout"
        />
      </div>
    </div>
  </div>
</template>
