<script setup>
defineProps({
  record: { type: Object, required: true }
})
</script>
<template>
  <div v-if="record" class="card p-4 space-y-3">
    <h3 class="text-sm font-semibold text-slate-300">📋 Ficha Clínica</h3>
    <div class="grid grid-cols-2 gap-3 text-sm">
      <div v-if="record.weight_kg">
        <p class="text-slate-500 text-xs">Peso</p>
        <p class="text-slate-300">{{ record.weight_kg }} kg</p>
      </div>
      <div v-if="record.temperature_c">
        <p class="text-slate-500 text-xs">Temperatura</p>
        <p class="text-slate-300">{{ record.temperature_c }}°C</p>
      </div>
      <div v-if="record.diagnosis" class="col-span-2">
        <p class="text-slate-500 text-xs">Diagnóstico</p>
        <p class="text-slate-300">{{ record.diagnosis }}</p>
      </div>
      <div v-if="record.treatment" class="col-span-2">
        <p class="text-slate-500 text-xs">Tratamiento</p>
        <p class="text-slate-300">{{ record.treatment }}</p>
      </div>
      <div v-if="record.prescriptions" class="col-span-2">
        <p class="text-slate-500 text-xs">Recetas</p>
        <p class="text-slate-300">{{ record.prescriptions }}</p>
      </div>
      <div v-if="record.observations" class="col-span-2">
        <p class="text-slate-500 text-xs">Observaciones</p>
        <p class="text-slate-300">{{ record.observations }}</p>
      </div>
      <div v-if="record.next_visit_rec" class="col-span-2">
        <p class="text-slate-500 text-xs">Próxima visita</p>
        <p class="text-brand-400">{{ record.next_visit_rec }}</p>
      </div>
    </div>
  </div>
  <div v-else class="card p-4 text-center text-slate-500 text-sm">
    Sin ficha clínica
  </div>
</template>
