<script setup>
defineProps({
  title: { type: String, default: '' },
  size:  { type: String, default: 'md' }, // sm | md | lg | xl
})
const emit = defineEmits(['close'])
</script>
<template>
  <Teleport to="body">
    <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" @click="$emit('close')" />
      <div
        class="relative card p-6 w-full shadow-2xl"
        :class="{
          'max-w-sm':  size === 'sm',
          'max-w-md':  size === 'md',
          'max-w-lg':  size === 'lg',
          'max-w-2xl': size === 'xl',
        }"
        @keydown.escape="$emit('close')"
        tabindex="-1"
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
