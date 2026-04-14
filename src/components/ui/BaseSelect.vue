<script setup>
defineProps({
  modelValue: { type: [String, Number], default: '' },
  label:      { type: String, default: '' },
  options:    { type: Array, default: () => [] }, // [{ value, label }]
  placeholder:{ type: String, default: 'Seleccionar...' },
  error:      { type: String, default: '' },
  required:   { type: Boolean, default: false },
})
defineEmits(['update:modelValue'])
</script>
<template>
  <div class="w-full">
    <label v-if="label" class="label-base">
      {{ label }} <span v-if="required" class="text-red-400">*</span>
    </label>
    <select
      :value="modelValue"
      class="input-base"
      :class="error && 'border-red-500'"
      @change="$emit('update:modelValue', $event.target.value)"
    >
      <option value="" disabled>{{ placeholder }}</option>
      <option v-for="opt in options" :key="opt.value" :value="opt.value">
        {{ opt.label }}
      </option>
    </select>
    <p v-if="error" class="mt-1 text-xs text-red-400">{{ error }}</p>
  </div>
</template>
