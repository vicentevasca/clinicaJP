<script setup>
import { ref, onMounted } from 'vue'
import { useAuth } from '@/composables/useAuth'
import { useToast } from '@/composables/useToast'
import { usersService } from '@/services/users.service'

const { profile, refreshProfile, logout } = useAuth()
const { addToast } = useToast()

const form = ref({
  name:  '',
  email: '',
  phone: '',
})
const saving = ref(false)


onMounted(() => {
  if (profile.value) {
    form.value = {
      name:  profile.value.name || '',
      email: profile.value.email || '',
      phone: profile.value.phone || '',
    }
  }
})

async function saveProfile() {
  saving.value = true
  try {
    await usersService.updateProfile(profile.value.id, {
      name:  form.value.name,
      phone: form.value.phone,
    })
    await refreshProfile()
    addToast('Perfil actualizado', 'success')
  } catch (e) {
    addToast('Error: ' + e.message, 'error')
  } finally {
    saving.value = false
  }
}

function confirmDelete() {
  if (confirm('¿Estás seguro de que quieres eliminar tu cuenta? Esta acción es irreversible y todos tus datos serán eliminados.')) {
    addToast('Para eliminar tu cuenta, contacta al administrador del sistema.', 'warning')
  }
}
</script>

<template>
  <div class="p-6 space-y-6 max-w-2xl">
    <div>
      <h1 class="text-2xl font-bold text-white">⚙️ Configuración</h1>
      <p class="text-slate-400 text-sm">Tu perfil y preferencias</p>
    </div>

    <!-- Perfil -->
    <div class="card p-5">
      <h3 class="text-sm font-semibold text-slate-300 mb-4">Perfil</h3>
      <form @submit.prevent="saveProfile" class="space-y-4">
        <div>
          <label class="label-base">Nombre</label>
          <input v-model="form.name" type="text" class="input-base" />
        </div>
        <div>
          <label class="label-base">Email</label>
          <input v-model="form.email" type="email" class="input-base" disabled />
          <p class="text-xs text-slate-600 mt-1">El email no se puede cambiar</p>
        </div>
        <div>
          <label class="label-base">Teléfono</label>
          <input v-model="form.phone" type="text" class="input-base" placeholder="+56..." />
        </div>
        <button type="submit" class="btn-primary" :disabled="saving">
          {{ saving ? 'Guardando...' : 'Guardar cambios' }}
        </button>
      </form>
    </div>

    <!-- Notificaciones -->
    <div class="card p-5">
      <h3 class="text-sm font-semibold text-slate-300 mb-2">Notificaciones</h3>
      <p class="text-xs text-slate-500">
        La configuración de notificaciones (email, Telegram, recordatorios) estará disponible próximamente.
        Las alertas activas se gestionan desde el Dashboard.
      </p>
    </div>

    <!-- Zona de peligro -->
    <div class="card p-5 border-red-500/20">
      <h3 class="text-sm font-semibold text-red-400 mb-3">Zona de peligro</h3>
      <p class="text-xs text-slate-500 mb-3">Eliminar tu cuenta es irreversible. Todos tus datos serán eliminados.</p>
      <button class="btn-secondary bg-red-500/20 border-red-500/30 text-red-400 hover:bg-red-500/30"
        @click="confirmDelete">
        Eliminar cuenta
      </button>
    </div>
  </div>
</template>
