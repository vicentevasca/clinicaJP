<script setup>
import { ref } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { useInventoryStore } from '@/stores/inventory'
import { useLeadsStore } from '@/stores/leads'
import { storeToRefs } from 'pinia'

const route         = useRoute()
const { profile, logout } = useAuth()
const inventoryStore = useInventoryStore()
const leadsStore     = useLeadsStore()
const { hasAlerts }   = storeToRefs(inventoryStore)
const { totalWaiting } = storeToRefs(leadsStore)

const sidebarOpen = ref(false)

const navItems = [
  { path: '/app/dashboard',      label: 'Dashboard',      icon: '📊' },
  { path: '/app/leads',          label: 'Leads',          icon: '📋' },
  { path: '/app/agenda',         label: 'Agenda',         icon: '📅' },
  { path: '/app/pacientes',      label: 'Pacientes',      icon: '🐾' },
  { path: '/app/inventario',     label: 'Inventario',     icon: '📦' },
  { path: '/app/procedimientos', label: 'Procedimientos', icon: '🩺' },
  { path: '/app/reportes',       label: 'Reportes',       icon: '📈' },
  { path: '/app/configuracion',  label: 'Configuración',  icon: '⚙️' },
]

function isActive(path) {
  return route.path === path || route.path.startsWith(path + '/')
}
</script>

<template>
  <div class="flex h-screen bg-slate-900 overflow-hidden">
    <!-- Sidebar -->
    <aside class="w-64 flex-shrink-0 bg-slate-800/80 border-r border-slate-700/60 flex flex-col">
      <!-- Logo -->
      <div class="h-16 flex items-center px-6 border-b border-slate-700/60">
        <span class="text-xl font-bold text-white">🐾 VetDesk</span>
      </div>

      <!-- Nav -->
      <nav class="flex-1 px-3 py-4 overflow-y-auto space-y-0.5">
        <RouterLink
          v-for="item in navItems" :key="item.path"
          :to="item.path"
          class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors"
          :class="isActive(item.path)
            ? 'bg-brand-600/20 text-brand-400'
            : 'text-slate-400 hover:text-slate-100 hover:bg-slate-700/60'"
        >
          <span class="text-base">{{ item.icon }}</span>
          <span>{{ item.label }}</span>
          <!-- Badge para leads en espera -->
          <span v-if="item.path === '/app/leads' && totalWaiting > 0"
            class="ml-auto badge bg-amber-500/20 text-amber-400 border border-amber-500/30">
            {{ totalWaiting }}
          </span>
          <!-- Badge para alertas de stock -->
          <span v-if="item.path === '/app/inventario' && hasAlerts"
            class="ml-auto w-2 h-2 rounded-full bg-red-500 animate-pulse" />
        </RouterLink>
      </nav>

      <!-- User -->
      <div class="p-4 border-t border-slate-700/60">
        <div class="flex items-center gap-3">
          <div class="w-8 h-8 rounded-full bg-brand-600 flex items-center justify-center text-white text-sm font-bold">
            {{ profile?.name?.charAt(0) || '?' }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-slate-200 truncate">{{ profile?.name }}</p>
            <p class="text-xs text-slate-500 capitalize">{{ profile?.role }}</p>
          </div>
          <button @click="logout" class="btn-ghost !px-2 !py-1 text-xs">Salir</button>
        </div>
      </div>
    </aside>

    <!-- Main content -->
    <main class="flex-1 overflow-y-auto">
      <RouterView />
    </main>
  </div>
</template>
