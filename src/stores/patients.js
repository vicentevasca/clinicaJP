import { defineStore } from 'pinia'
import { ref } from 'vue'
import { patientsService } from '@/services/patients.service'

export const usePatientsStore = defineStore('patients', () => {
  const animals = ref([])
  const clients = ref([])
  const loading = ref(false)
  const error   = ref(null)

  async function fetchAnimals(filters = {}) {
    loading.value = true
    error.value   = null
    try {
      animals.value = await patientsService.getAnimals(filters)
    } catch (e) {
      error.value = e.message
    } finally {
      loading.value = false
    }
  }

  return { animals, clients, loading, error, fetchAnimals }
})
