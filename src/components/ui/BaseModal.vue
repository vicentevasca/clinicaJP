<script setup>
import { onMounted, onBeforeUnmount } from 'vue'
defineProps({
  title:     { type: String, default: '' },
  size:      { type: String, default: 'md' }, // sm | md | lg | xl
})
const emit = defineEmits(['close'])
function onKeydown(e) { if (e.key === 'Escape') emit('close') }
onMounted(()       => document.addEventListener('keydown', onKeydown))
onBeforeUnmount(() => document.removeEventListener('keydown', onKeydown))
</script>
<template>
  <Teleport to="body">
    <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" @click="$emit('close')" />
      <div
        class="relative card p-6 w-full shadow-2xl"
        :class="{
          'max-w-sm':  size === 'sm',
          'max-w-md':  size === 'md',
          'max-w-lg':  size === 'lg',
          'max-w-2xl': size === 'xl',
        }"
      >
        <div v-if="title" class="flex items-center justify-between mb-5">
          <h2 class="text-lg font-semibold text-white">{{ title }}</h2>
          <button @click="$emit('close')" class="btn-ghost !p-1.5 text-slate-400">✕</button>
        </div>
        <slot />
      </div>
    </div>
  </Teleport>
</template>
