import { defineStore } from 'pinia'
import { ref } from 'vue'
import { visitsService } from '@/services/visits.service'

export const useAgendaStore = defineStore('agenda', () => {
  const visits  = ref([])
  const loading = ref(false)
  const error   = ref(null)

  async function fetchByRange(from, to) {
    loading.value = true
    error.value   = null
    try {
      visits.value = await visitsService.getByRange(from, to)
    } catch (e) {
      error.value = e.message
    } finally {
      loading.value = false
    }
  }

  return { visits, loading, error, fetchByRange }
})
