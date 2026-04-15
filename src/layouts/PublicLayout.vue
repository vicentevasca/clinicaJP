<script setup>
import PublicNavbar from '@/components/public/PublicNavbar.vue'
</script>

<template>
  <div class="min-h-screen" style="background-color: var(--bg-primary);">
    <PublicNavbar />
    <slot />
  </div>
</template>
