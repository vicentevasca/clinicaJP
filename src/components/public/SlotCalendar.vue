<script setup>
import { ref, onMounted } from 'vue'
import { availabilityService } from '@/services/availability.service'
import TimeSlotPicker from './TimeSlotPicker.vue'

const props = defineProps({
  modelValue: { type: Object, default: null }, // { date, time_slot }
})

const emit = defineEmits(['update:modelValue'])

const slots = ref([])
const loading = ref(true)
const error = ref(null)

async function loadSlots() {
  loading.value = true
  error.value = null
  try {
    slots.value = await availabilityService.getAvailableSlots(7)
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

function selectSlot(date, timeSlot) {
  emit('update:modelValue', { date, time_slot: timeSlot })
}

function isSelected(date, timeSlot) {
  return props.modelValue?.date === date && props.modelValue?.time_slot === timeSlot
}

onMounted(loadSlots)
</script>

<template>
  <div>
    <!-- Loading skeleton -->
    <div v-if="loading" class="grid grid-cols-7 gap-2">
      <div v-for="i in 7" :key="i" class="bg-slate-800 rounded-lg h-24 animate-pulse" />
    </div>

    <!-- Error -->
    <div v-else-if="error" class="text-red-400 text-sm text-center py-4">
      No se pudo cargar la disponibilidad
    </div>

    <!-- Slots calendar -->
    <div v-else class="space-y-2">
      <div
        v-for="day in slots"
        :key="day.date"
        class="flex items-center gap-3 py-2 border-b border-slate-700/50 last:border-0"
      >
        <!-- Day header -->
        <div class="w-16 flex-shrink-0">
          <div class="text-xs text-slate-500 uppercase tracking-wide">{{ day.day_name.slice(0, 3) }}</div>
          <div class="text-lg font-bold text-white">{{ new Date(day.date + 'T12:00:00').getDate() }}</div>
        </div>

        <!-- Slots -->
        <div class="flex gap-2 flex-1">
          <TimeSlotPicker
            v-for="(slotInfo, slotKey) in day.time_slots"
            :key="slotKey"
            :slot="{ ...slotInfo, time_slot: slotKey }"
            :selected="isSelected(day.date, slotKey)"
            @select="selectSlot(day.date, $event.time_slot)"
          />
        </div>
      </div>
    </div>

    <!-- Refresh button -->
    <button
      type="button"
      @click="loadSlots"
      class="mt-3 text-xs text-slate-500 hover:text-slate-300 transition-colors"
    >
      🔄 Actualizar disponibilidad
    </button>
  </div>
</template>
