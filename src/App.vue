<script setup>
import { ref, onMounted } from 'vue'
import { useTheme } from '@/composables/useTheme'
import AppLayout    from '@/layouts/AppLayout.vue'
import PublicLayout from '@/layouts/PublicLayout.vue'
import BaseToast    from '@/components/ui/BaseToast.vue'

const route = ref(null)
const { init: initTheme } = useTheme()

onMounted(async () => {
  // Dynamic imports ensure stores run AFTER app.use(createPinia()) and app.use(router)
  const [{ useRoute }, { useAuthStore }] = await Promise.all([
    import('vue-router'),
    import('@/stores/auth')
  ])
  route.value = useRoute()
  useAuthStore().init()
  initTheme()
})
</script>

<template>
  <AppLayout    v-if="route.meta.requiresAuth">
    <RouterView />
  </AppLayout>
  <PublicLayout v-else-if="route.meta.layout === 'public'">
    <RouterView />
  </PublicLayout>
  <RouterView v-else />

  <BaseToast />
</template>
