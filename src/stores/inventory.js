import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { inventoryService } from '@/services/inventory.service'

export const useInventoryStore = defineStore('inventory', () => {
  const items   = ref([])
  const loading = ref(false)
  const error   = ref(null)

  const lowStockItems = computed(() =>
    items.value.filter(i => i.stock <= i.min_stock)
  )
  const hasAlerts = computed(() => lowStockItems.value.length > 0)

  async function fetchAll() {
    loading.value = true
    error.value   = null
    try {
      items.value = await inventoryService.getAll()
    } catch (e) {
      error.value = e.message
    } finally {
      loading.value = false
    }
  }

  return { items, loading, error, lowStockItems, hasAlerts, fetchAll }
})
