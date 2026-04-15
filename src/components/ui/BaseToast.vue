<script setup>
import { onMounted, ref } from 'vue'
import { storeToRefs } from 'pinia'

const store = ref(null)
const toasts = ref([])
const dismiss = ref(null)

onMounted(async () => {
  const { useNotificationsStore } = await import('@/stores/notifications')
  store.value = useNotificationsStore()
  toasts.value = storeToRefs(store.value).toasts
  dismiss.value = store.value.dismiss
})

const icons = { success: '✓', error: '✕', warning: '⚠', info: 'ℹ' }
const colors = {
  success: 'bg-brand-600 border-brand-500',
  error:   'bg-red-700 border-red-600',
  warning: 'bg-amber-600 border-amber-500',
  info:    'bg-blue-700 border-blue-600',
}
</script>
<template>
  <Teleport to="body">
    <div class="fixed bottom-5 right-5 z-[100] flex flex-col gap-2 max-w-sm w-full px-4">
      <TransitionGroup name="toast" tag="div" class="flex flex-col gap-2">
        <div
          v-for="toast in toasts" :key="toast.id"
          class="flex items-start gap-3 px-4 py-3 rounded-lg border text-sm text-white shadow-xl"
          :class="colors[toast.type] || colors.info"
        >
          <span class="font-bold">{{ icons[toast.type] || 'ℹ' }}</span>
          <span class="flex-1">{{ toast.message }}</span>
          <button @click="dismiss(toast.id)" class="opacity-60 hover:opacity-100">✕</button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>
<style scoped>
.toast-enter-active, .toast-leave-active { transition: all 0.3s ease; }
.toast-enter-from  { opacity: 0; transform: translateX(100%); }
.toast-leave-to    { opacity: 0; transform: translateX(100%); }
</style>
