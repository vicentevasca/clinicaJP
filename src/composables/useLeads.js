import { useLeadsStore } from '@/stores/leads'
import { storeToRefs } from 'pinia'

export function useLeads() {
  const store = useLeadsStore()
  const { items, loading, error, byStatus, totalWaiting } = storeToRefs(store)
  return { items, loading, error, byStatus, totalWaiting,
           fetchAll: store.fetchAll, updateStatus: store.updateStatus }
}
