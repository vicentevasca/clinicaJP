<script setup>
import { watch, ref } from 'vue'
import { useTheme } from '@/composables/useTheme'

const { isDark } = useTheme()

const props = defineProps({
  title: { type: String, default: '' },
  size:  { type: String, default: 'md' }, // sm | md | lg | xl
  show:  { type: Boolean, default: false },
})
const emit = defineEmits(['close'])

const modalRef = ref(null)

watch(() => props.show, (v) => {
  if (v) {
    document.body.style.overflow = 'hidden'
    // Focus para que keydown funcione
    setTimeout(() => modalRef.value?.focus(), 10)
  } else {
    document.body.style.overflow = ''
  }
})

function handleKeydown(e) {
  if (e.key === 'Escape') emit('close')
}
</script>
<template>
  <Teleport to="body">
    <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center p-4"
      :class="isDark ? 'theme-soft-dark' : ''"
      @keydown="handleKeydown">
      <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" @click="$emit('close')" />
      <div
        ref="modalRef"
        class="relative card p-6 w-full shadow-2xl"
        :class="{
          'max-w-sm':  size === 'sm',
          'max-w-md':  size === 'md',
          'max-w-lg':  size === 'lg',
          'max-w-2xl': size === 'xl',
        }"
        tabindex="-1"
      >
        <div v-if="title" class="flex items-center justify-between mb-5">
          <h2 class="text-lg font-semibold" style="color: var(--text-primary);">{{ title }}</h2>
          <button @click="$emit('close')" class="btn-ghost !p-1.5" style="color: var(--text-muted);">✕</button>
        </div>
        <slot />
      </div>
    </div>
  </Teleport>
</template>
