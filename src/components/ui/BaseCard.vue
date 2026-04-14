<script setup>
defineProps({
  padding: { type: String, default: 'p-5' },
  hover:   { type: Boolean, default: false },
})
</script>
<template>
  <div class="card" :class="[padding, hover && 'hover:border-slate-600 transition-colors cursor-pointer']">
    <slot />
  </div>
</template>
