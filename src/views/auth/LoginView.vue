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
    toast.error('Error al iniciar sesión')
  } finally {
    loading.value = false
  }
}
</script>
<template>
  <div class="min-h-screen bg-slate-900 flex items-center justify-center px-4">
    <div class="w-full max-w-sm">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-white">🐾 VetDesk</h1>
        <p class="text-slate-400 mt-2">Panel de administración</p>
      </div>
      <div class="card p-6 space-y-4">
        <BaseInput v-model="email"    label="Email"      type="email"    required />
        <BaseInput v-model="password" label="Contraseña" type="password" required />
        <p v-if="error" class="text-red-400 text-sm">{{ error }}</p>
        <BaseButton class="w-full" :loading="loading" @click="handleLogin">
          Ingresar
        </BaseButton>
      </div>
    </div>
  </div>
</template>
