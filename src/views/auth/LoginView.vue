<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { useToast } from '@/composables/useToast'
import BaseInput  from '@/components/ui/BaseInput.vue'
import BaseButton from '@/components/ui/BaseButton.vue'

const router  = useRouter()
const { login } = useAuth()
const toast   = useToast()

const email    = ref('')
const password = ref('')
const loading  = ref(false)
const error    = ref('')

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    await login(email.value, password.value)
    router.push('/app/dashboard')
  } catch (e) {
    error.value = 'Credenciales incorrectas.'
    toast.addToast('Error al iniciar sesión', 'error')
  } finally {
    loading.value = false
  }
}
</script>
<template>
  <div class="min-h-screen bg-[var(--bg-primary)] flex items-center justify-center px-4">
    <div class="w-full max-w-sm">
      <div class="text-center mb-8">
        <div class="flex justify-center mb-3">
          <svg xmlns="http://www.w3.org/2000/svg" class="w-12 h-12 text-[var(--btn-primary-bg)]" viewBox="0 0 24 24" fill="currentColor">
            <circle cx="12" cy="12" r="10" opacity="0.2" />
            <path d="M12 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm-3 4c0-1.1.9-2 2-2s2 .9 2 2-.9 2-2 2-2-.9-2-2zm6 0c0-1.1.9-2 2-2s2 .9 2 2-.9 2-2 2-2-.9-2-2zm-9 4c0-1.1.9-2 2-2s2 .9 2 2-.9 2-2 2-2-.9-2-2zm6 0c0-1.1.9-2 2-2s2 .9 2 2-.9 2-2 2-2-.9-2-2zm-3 4c-2 0-3.5 1.5-3.5 3.5S8.5 21 10.5 21s3.5-1.5 3.5-3.5S13.5 14 11.5 14z" opacity="0.8"/>
          </svg>
        </div>
        <h1 class="text-3xl font-semibold text-[var(--text-primary)]">VetDesk</h1>
        <p class="text-[var(--text-secondary)] mt-2">Panel de administración</p>
      </div>
      <form class="card p-6 space-y-4" @submit.prevent="handleLogin">
        <BaseInput v-model="email"    label="Email"      type="email"    required autocomplete="email" />
        <BaseInput v-model="password" label="Contraseña" type="password" required autocomplete="current-password" />
        <p v-if="error" class="text-sm" style="color: var(--text-error)">{{ error }}</p>
        <BaseButton type="submit" class="w-full" :loading="loading">
          Ingresar
        </BaseButton>
      </form>
    </div>
  </div>
</template>
