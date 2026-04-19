import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '@/services/supabase'

export const useAuthStore = defineStore('auth', () => {
  const user    = ref(null)
  const profile = ref(null)
  const loading = ref(true)

  const isAdmin    = computed(() => profile.value?.role === 'admin')
  const isTecnico  = computed(() => ['admin','tecnico'].includes(profile.value?.role))
  const isLoggedIn = computed(() => !!user.value)

  async function init() {
    loading.value = true
    const { data: { session } } = await supabase.auth.getSession()
    if (session?.user) {
      user.value = session.user
      await loadProfile()
    }
    // Escuchar cambios de sesión
    supabase.auth.onAuthStateChange(async (_event, session) => {
      user.value = session?.user ?? null
      if (user.value) await loadProfile()
      else profile.value = null
    })
    loading.value = false
  }

  async function loadProfile() {
    const { data } = await supabase
      .from('users').select('*').eq('id', user.value.id).single()
    profile.value = data
  }

  async function login(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
    user.value = data.user
    await loadProfile()
    return data
  }

  async function logout() {
    await supabase.auth.signOut()
    user.value = null
    profile.value = null
  }

  return { user, profile, loading, isAdmin, isTecnico, isLoggedIn, init, login, logout, loadProfile }
})
