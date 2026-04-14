<script setup>
import { LEAD_STATUS_COLORS, LEAD_STATUS_LABELS } from '@/utils/constants'

const props = defineProps({
  status: { type: String, required: true }
})
</script>
<template>
  <span class="badge" :class="LEAD_STATUS_COLORS[status]">
    {{ LEAD_STATUS_LABELS[status] }}
  </span>
</template>
