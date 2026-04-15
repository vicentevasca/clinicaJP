<script setup>
import { computed } from 'vue'
import { useWhatsApp } from '@/composables/useWhatsApp'
import { buildWALinkFromLead, WA_TEMPLATES } from '@/utils/whatsapp'

const props = defineProps({
  lead: { type: Object, required: true },
  template: { type: String, default: 'initial_contact' },
})

const { copied, copyText } = useWhatsApp()

const waUrl = computed(() => buildWALinkFromLead(props.lead))
const waText = computed(() => {
  const t = WA_TEMPLATES[props.template]
  if (!t) return ''
  return t(
    props.lead.client?.name || 'Cliente',
    props.lead.animal?.name || 'tu mascota'
  )
})
</script>

<template>
  <div class="card p-4">
    <h4 class="text-sm font-semibold text-slate-300 mb-3">💬 WhatsApp</h4>
    <div class="bg-slate-900 rounded-lg p-3 text-sm text-slate-300 mb-3 whitespace-pre-wrap">{{ waText }}</div>
    <div class="flex gap-2">
      <button @click="copyText(waText)" class="btn-secondary flex-1 text-sm">
        {{ copied ? '¡Copiado!' : 'Copiar texto' }}
      </button>
      <a v-if="waUrl" :href="waUrl" target="_blank" class="btn-primary flex-1 text-sm text-center">
        Abrir WhatsApp
      </a>
    </div>
  </div>
</template>
