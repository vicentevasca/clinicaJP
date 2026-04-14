<script setup>
defineProps({
  variant: { type: String, default: 'default' }, // default | success | warning | danger | info
})
const classes = {
  default: 'bg-slate-500/20 text-slate-400 border border-slate-500/30',
  success: 'bg-brand-500/20 text-brand-400 border border-brand-500/30',
  warning: 'bg-amber-500/20 text-amber-400 border border-amber-500/30',
  danger:  'bg-red-500/20 text-red-400 border border-red-500/30',
  info:    'bg-blue-500/20 text-blue-400 border border-blue-500/30',
}
</script>
<template>
  <span class="badge" :class="classes[variant] || classes.default"><slot /></span>
</template>
