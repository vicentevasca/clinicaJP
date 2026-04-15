import { useNotificationsStore } from '@/stores/notifications'

export function useToast() {
  const store = useNotificationsStore()
  return {
    success: store.success,
    error:   store.error,
    warning: store.warning,
    show:    store.show,
    addToast: (msg, type = 'success') => store.show(msg, type), // alias para compatibilidad
  }
}
