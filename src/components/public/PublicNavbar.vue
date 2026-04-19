<script setup>
import { ref } from 'vue'
import { RouterLink } from 'vue-router'
import ThemeToggle from '@/components/ui/ThemeToggle.vue'

defineProps({
  showNavLinks: { type: Boolean, default: true }
})

const mobileOpen = ref(false)
</script>

<template>
  <nav class="fixed top-0 left-0 right-0 z-50 border-b transition-colors duration-300 nav-bar backdrop-blur-md">
    <div class="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">

      <!-- Hamburger (mobile only) -->
      <button
        v-if="showNavLinks"
        type="button"
        class="sm:hidden flex flex-col justify-center items-center w-9 h-9 rounded-lg gap-1.5 transition-colors hamburger-btn"
        :aria-expanded="mobileOpen"
        aria-label="Menú"
        @click="mobileOpen = !mobileOpen"
      >
        <span
          class="hamburger-line"
          :class="mobileOpen ? 'rotate-45 translate-y-[7px]' : ''"
        ></span>
        <span
          class="hamburger-line"
          :class="mobileOpen ? 'opacity-0' : ''"
        ></span>
        <span
          class="hamburger-line"
          :class="mobileOpen ? '-rotate-45 -translate-y-[7px]' : ''"
        ></span>
      </button>
      <!-- Placeholder to keep logo centered when no hamburger -->
      <div v-else class="w-9 sm:hidden"></div>

      <!-- Logo -->
      <RouterLink to="/" class="flex items-center gap-2.5 group">
        <div class="logo-icon">
          <svg class="w-5 h-5 text-white" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 14.5v-9l6 4.5-6 4.5z"/>
          </svg>
        </div>
        <span class="text-xl font-bold nav-text">VetDesk</span>
      </RouterLink>

      <!-- Right side -->
      <div class="flex items-center gap-3">
        <template v-if="showNavLinks">
          <a href="#servicios" class="nav-link hidden sm:flex">Servicios</a>
          <a href="#como-funciona" class="nav-link hidden sm:flex">Cómo funciona</a>
          <RouterLink to="/mi-mascota" class="nav-link-accent hidden sm:flex">Mi Mascota</RouterLink>
        </template>

        <RouterLink to="/solicitar" class="btn-primary text-sm shadow-sm">
          Solicitar visita
        </RouterLink>

        <ThemeToggle />
      </div>
    </div>

    <!-- Mobile menu -->
    <div
      v-if="showNavLinks && mobileOpen"
      class="sm:hidden mobile-menu border-t"
    >
      <div class="px-6 py-4 flex flex-col gap-1">
        <a
          href="#servicios"
          class="mobile-link"
          @click="mobileOpen = false"
        >
          Servicios
        </a>
        <a
          href="#como-funciona"
          class="mobile-link"
          @click="mobileOpen = false"
        >
          Cómo funciona
        </a>
        <RouterLink
          to="/mi-mascota"
          class="mobile-link mobile-link-accent"
          @click="mobileOpen = false"
        >
          Mi Mascota 🐾
        </RouterLink>
      </div>
    </div>
  </nav>
</template>

<style scoped>
.nav-bar {
  background-color: var(--nav-bg);
  border-color: var(--nav-border);
}

.logo-icon {
  width: 2rem;
  height: 2rem;
  border-radius: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--btn-primary-bg);
  transition: background-color 0.15s;
}

.nav-text {
  color: var(--text-primary);
  transition: color 0.15s;
}

.nav-link {
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--text-secondary);
  transition: color 0.15s;
}

.nav-link:hover {
  color: var(--btn-primary-bg);
}

.nav-link-accent {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--btn-primary-bg);
  transition: opacity 0.15s;
}

.nav-link-accent:hover {
  opacity: 0.8;
}

/* Hamburger button */
.hamburger-btn {
  background-color: transparent;
}

.hamburger-btn:hover {
  background-color: var(--brand-alpha);
}

.hamburger-line {
  display: block;
  width: 1.25rem;
  height: 2px;
  border-radius: 9999px;
  background-color: var(--text-primary);
  transition: transform 0.2s ease, opacity 0.2s ease;
}

/* Mobile menu */
.mobile-menu {
  background-color: var(--nav-bg);
  border-color: var(--nav-border);
}

.mobile-link {
  display: block;
  padding: 0.625rem 0.75rem;
  border-radius: 0.5rem;
  font-size: 0.9375rem;
  font-weight: 500;
  color: var(--text-secondary);
  transition: background-color 0.15s, color 0.15s;
}

.mobile-link:hover {
  background-color: var(--brand-alpha);
  color: var(--btn-primary-bg);
}

.mobile-link-accent {
  font-weight: 600;
  color: var(--btn-primary-bg);
}

.mobile-link-accent:hover {
  background-color: var(--brand-alpha);
  color: var(--btn-primary-bg);
}
</style>
