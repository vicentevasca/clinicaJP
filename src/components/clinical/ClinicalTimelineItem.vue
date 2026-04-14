<script setup>
defineProps({
  record: { type: Object, required: true }
})
</script>
<template>
  <div class="border-l border-slate-700 pl-4 py-1 relative">
    <div class="absolute left-[-5px] top-2 w-2 h-2 rounded-full bg-brand-500" />
    <div class="flex items-start justify-between mb-1">
      <p class="text-sm font-medium text-slate-300">
        {{ new Date(record.created_at).toLocaleDateString('es-CL') }}
      </p>
      <span v-if="record.temperature_c" class="text-xs text-slate-500">
        🌡 {{ record.temperature_c }}°C
      </span>
    </div>
    <p v-if="record.diagnosis" class="text-xs text-slate-400 mb-1">
      <span class="text-slate-500">Dx:</span> {{ record.diagnosis }}
    </p>
    <p v-if="record.treatment" class="text-xs text-slate-400 mb-1">
      <span class="text-slate-500">Rx:</span> {{ record.treatment }}
    </p>
    <p v-if="record.prescriptions" class="text-xs text-slate-400">
      <span class="text-slate-500">Rx extra:</span> {{ record.prescriptions }}
    </p>
  </div>
</template>
