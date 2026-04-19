<script setup>
import { onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useTheme } from '@/composables/useTheme'
import { useAuthStore } from '@/stores/auth'
import AppLayout    from '@/layouts/AppLayout.vue'
import PublicLayout from '@/layouts/PublicLayout.vue'
import BaseToast    from '@/components/ui/BaseToast.vue'

const route = useRoute()
const { init: initTheme } = useTheme()
const authStore = useAuthStore()

onMounted(() => {
  authStore.init()
  initTheme()
})
</script>

<template>
  <AppLayout    v-if="route.meta?.requiresAuth">
    <RouterView />
  </AppLayout>
  <PublicLayout v-else-if="route.meta?.layout === 'public'">
    <RouterView />
  </PublicLayout>
  <RouterView v-else />

  <BaseToast />
</template>
