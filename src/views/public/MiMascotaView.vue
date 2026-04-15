<script setup>
import { ref, onMounted } from 'vue'
import { gsap } from 'gsap'
import { clientsService } from '@/services/clients.service'
import { useToast } from '@/composables/useToast'
import PublicNavbar from '@/components/public/PublicNavbar.vue'
import ClientSearchForm from '@/components/public/ClientSearchForm.vue'
import ClientDashboard from '@/components/public/ClientDashboard.vue'

const toast = useToast()

const view = ref('search') // 'search' | 'dashboard'
const client = ref(null)
const animals = ref([])
const loading = ref(false)
const error = ref('')
const dashboardRef = ref(null)

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

onMounted(() => {
  if (prefersReducedMotion) return
  gsap.from('.animate-in', { opacity: 0, y: 20, stagger: 0.12, duration: 0.5, delay: 0.1 })
})

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
  <div class="min-h-screen bg-[var(--bg-primary)] pt-16">
    <PublicNavbar :showNavLinks="false" />

    <!-- Content -->
    <div class="max-w-4xl mx-auto px-6 py-12">
      <!-- Search view -->
      <div v-if="view === 'search'" class="pt-8">
        <ClientSearchForm @search="handleSearch" />
        <p v-if="error" class="text-sm text-center mt-4" style="color: var(--text-error)">{{ error }}</p>
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
