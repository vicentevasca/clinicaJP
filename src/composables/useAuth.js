import { useAuthStore } from '@/stores/auth'
import { storeToRefs } from 'pinia'

export function useAuth() {
  const store = useAuthStore()
  const { user, profile, loading, isAdmin, isTecnico, isLoggedIn } = storeToRefs(store)
  return { user, profile, loading, isAdmin, isTecnico, isLoggedIn,
           login: store.login, logout: store.logout,
           refreshProfile: store.loadProfile }
}
