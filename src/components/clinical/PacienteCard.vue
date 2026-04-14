<script setup>
import { RouterLink } from 'vue-router'

defineProps({
  animal: { type: Object, required: true }
})

const speciesEmoji = {
  perro: '🐕', gato: '🐈', ave: '🐦', gallina: '🐔', caballo: '🐴', bovino: '🐄', otro: '🐾'
}
</script>
<template>
  <RouterLink :to="`/app/pacientes/${animal.id}`"
    class="card p-4 hover:border-brand-500/40 transition-all hover:scale-[1.01] animate-in cursor-pointer">
    <div class="flex items-center gap-3 mb-3">
      <div class="w-12 h-12 rounded-full bg-slate-700/60 flex items-center justify-center text-2xl">
        {{ speciesEmoji[animal.species] || '🐾' }}
      </div>
      <div>
        <p class="font-semibold text-white">{{ animal.name }}</p>
        <p class="text-xs text-slate-500 capitalize">{{ animal.breed || animal.species }}</p>
      </div>
    </div>
    <div class="text-xs text-slate-400 space-y-1">
      <p>👤 {{ animal.client?.name }}</p>
      <p>📱 {{ animal.client?.phone }}</p>
      <p v-if="animal.sex">⚥ {{ animal.sex }}</p>
    </div>
  </RouterLink>
</template>
