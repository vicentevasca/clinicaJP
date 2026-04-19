<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { RouterLink } from 'vue-router'
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

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

onMounted(() => {
  if (prefersReducedMotion) return
  gsap.from('.hero-animate', {
    opacity: 0, y: 20, stagger: 0.1, duration: 0.5, delay: 0.1, ease: 'power2.out'
  })
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
    window.scrollTo({ top: 0, behavior: 'smooth' })
  } catch (e) {
    error.value = e.message === 'Cliente no encontrado'
      ? 'No encontramos ningún cliente con ese identificador. Verifica que el RUT o teléfono sean los mismos que ingresaste al solicitar la visita.'
      : 'Error al buscar. Por favor intenta nuevamente.'
    toast.error(error.value)
  } finally {
    loading.value = false
  }
}

function handleLogout() {
  view.value = 'search'
  client.value = null
  animals.value = []
  error.value = ''
  window.scrollTo({ top: 0, behavior: 'smooth' })
}
</script>

<template>
  <div class="min-h-screen pt-16" style="background-color: var(--bg-primary);">
    <PublicNavbar :showNavLinks="false" />

    <!-- ══ SEARCH VIEW ═══════════════════════════════════ -->
    <div v-if="view === 'search'" class="max-w-lg mx-auto px-4 py-14">

      <!-- Welcome header -->
      <div class="text-center mb-10 hero-animate">
        <div
          class="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-5 text-3xl"
          style="background-color: var(--brand-alpha); border: 1.5px solid var(--border-color);"
          aria-hidden="true"
        >
          🐾
        </div>

        <h1 class="text-3xl sm:text-4xl font-bold mb-3" style="color: var(--text-primary);">
          Portal Mi Mascota
        </h1>
        <p class="text-base max-w-sm mx-auto leading-relaxed" style="color: var(--text-secondary);">
          Consulta el historial clínico de tu mascota, revisa vacunas y solicita nuevas atenciones.
        </p>

        <!-- Feature pills -->
        <div class="flex flex-wrap items-center justify-center gap-2 mt-5">
          <span
            class="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg); border: 1px solid var(--border-color);"
          >
            📋 Historial clínico
          </span>
          <span
            class="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg); border: 1px solid var(--border-color);"
          >
            💉 Vacunas aplicadas
          </span>
          <span
            class="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg); border: 1px solid var(--border-color);"
          >
            ⚖️ Historial de peso
          </span>
          <span
            class="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-full"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg); border: 1px solid var(--border-color);"
          >
            🏠 Solicitar visita
          </span>
        </div>
      </div>

      <!-- Search form -->
      <div class="hero-animate">
        <ClientSearchForm :loading="loading" @search="handleSearch" />
      </div>

      <!-- Error message -->
      <div
        v-if="error"
        class="mt-4 p-4 rounded-xl text-sm text-center hero-animate"
        style="background-color: rgba(239,68,68,0.08); border: 1px solid rgba(239,68,68,0.2); color: var(--text-error);"
      >
        {{ error }}
      </div>

      <!-- Help note -->
      <div class="mt-8 text-center hero-animate">
        <p class="text-xs" style="color: var(--text-muted);">
          ¿Primera vez con nosotros?
          <RouterLink
            to="/solicitar"
            class="font-semibold underline underline-offset-2 transition-opacity hover:opacity-70"
            style="color: var(--btn-primary-bg);"
          >
            Solicita tu primera visita →
          </RouterLink>
        </p>
      </div>
    </div>

    <!-- ══ DASHBOARD VIEW ════════════════════════════════ -->
    <div v-else class="max-w-4xl mx-auto px-4 py-8">
      <ClientDashboard
        v-if="client"
        :client="client"
        :animals="animals"
        @logout="handleLogout"
      />
    </div>

  </div>
</template>
