import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { leadsService } from '@/services/leads.service'
import { LEAD_STATUS } from '@/utils/constants'

export const useLeadsStore = defineStore('leads', () => {
  const items   = ref([])
  const loading = ref(false)
  const error   = ref(null)

  const byStatus = computed(() => ({
    waiting:     items.value.filter(l => l.status === LEAD_STATUS.WAITING),
    in_progress: items.value.filter(l => l.status === LEAD_STATUS.IN_PROGRESS),
    done:        items.value.filter(l => l.status === LEAD_STATUS.DONE),
    cancelled:   items.value.filter(l => l.status === LEAD_STATUS.CANCELLED),
  }))

  const totalWaiting = computed(() => byStatus.value.waiting.length)

  async function fetchAll(filters = {}) {
    loading.value = true
    error.value   = null
    try {
      items.value = await leadsService.getAll(filters)
    } catch (e) {
      error.value = e.message
    } finally {
      loading.value = false
    }
  }

  async function updateStatus(id, newStatus, note = '') {
    try {
      const updated = await leadsService.updateStatus(id, newStatus, note)
      const idx = items.value.findIndex(l => l.id === id)
      if (idx !== -1) items.value[idx] = { ...items.value[idx], ...updated }
      return updated
    } catch (e) {
      error.value = e.message
      throw e
    }
  }

  return { items, loading, error, byStatus, totalWaiting, fetchAll, updateStatus }
})
