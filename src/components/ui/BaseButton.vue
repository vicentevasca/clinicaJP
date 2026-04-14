<script setup>
defineProps({
  variant:  { type: String, default: 'primary' }, // primary | secondary | ghost | danger
  size:     { type: String, default: 'md' },       // sm | md | lg
  loading:  { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
  type:     { type: String, default: 'button' },
})
</script>
<template>
  <button
    :type="type"
    :disabled="disabled || loading"
    :class="[
      variant === 'primary'   && 'btn-primary',
      variant === 'secondary' && 'btn-secondary',
      variant === 'ghost'     && 'btn-ghost',
      variant === 'danger'    && 'inline-flex items-center gap-2 px-4 py-2.5 rounded-lg bg-red-600 hover:bg-red-500 text-white text-sm font-medium transition-colors disabled:opacity-50',
      size === 'sm'  && '!text-xs !px-3 !py-1.5',
      size === 'lg'  && '!text-base !px-6 !py-3',
    ]"
  >
    <span v-if="loading" class="spinner !w-4 !h-4" />
    <slot />
  </button>
</template>
