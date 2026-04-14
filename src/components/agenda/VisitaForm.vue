<script setup>
import { ref, watch } from 'vue'
import { visitsService } from '@/services/visits.service'
import { useToast } from '@/composables/useToast'
import BaseModal from '@/components/ui/BaseModal.vue'
import { SERVICE_TYPES } from '@/utils/constants'

const props = defineProps({
  show:   { type: Boolean, default: false },
  visit:  { type: Object, default: null },
  leadId: { type: String, default: null },
})
const emit = defineEmits(['close', 'saved'])

const { addToast } = useToast()

const form = ref({
  client_id:    '',
  animal_id:    '',
  assigned_to:  '',
  scheduled_at: '',
  duration_min: 60,
  address:      '',
  notes:        '',
})
const saving = ref(false)

watch(() => props.show, async (v) => {
  if (v) {
    if (props.visit) {
      form.value = {
        client_id:    props.visit.client_id,
        animal_id:    props.visit.animal_id,
        assigned_to:  props.visit.assigned_to,
        scheduled_at: props.visit.scheduled_at.slice(0, 16),
        duration_min: props.visit.duration_min || 60,
        address:      props.visit.address,
        notes:        props.visit.notes || '',
      }
    } else {
      form.value = {
        client_id: '', animal_id: '', assigned_to: '',
        scheduled_at: new Date().toISOString().slice(0, 16),
        duration_min: 60, address: '', notes: ''
      }
    }
  }
})

async function save() {
  saving.value = true
  try {
    if (props.visit) {
      const { supabase } = await import('@/services/supabase')
      await supabase.from('visits').update({
        scheduled_at: form.value.scheduled_at,
        duration_min: form.value.duration_min,
        address:      form.value.address,
        notes:        form.value.notes,
      }).eq('id', props.visit.id)
    } else {
      await visitsService.create({
        lead_id:      props.leadId,
        client_id:    form.value.client_id,
        animal_id:    form.value.animal_id,
        assigned_to:  form.value.assigned_to,
        scheduled_at: form.value.scheduled_at,
        duration_min: form.value.duration_min,
        address:      form.value.address,
        notes:        form.value.notes,
      })
    }
    addToast(props.visit ? 'Visita actualizada' : 'Visita creada', 'success')
    emit('saved')
    emit('close')
  } catch (e) {
    addToast('Error: ' + e.message, 'error')
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <BaseModal :show="show" :title="visit ? 'Editar Visita' : 'Nueva Visita'" size="lg" @close="$emit('close')">
    <form @submit.prevent="save" class="space-y-4">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="label-base">Fecha y hora *</label>
          <input v-model="form.scheduled_at" type="datetime-local" class="input-base" required />
        </div>
        <div>
          <label class="label-base">Duración (min)</label>
          <input v-model.number="form.duration_min" type="number" class="input-base" min="15" step="15" />
        </div>
        <div class="md:col-span-2">
          <label class="label-base">Dirección *</label>
          <input v-model="form.address" type="text" class="input-base" required />
        </div>
        <div class="md:col-span-2">
          <label class="label-base">Notas</label>
          <textarea v-model="form.notes" class="input-base" rows="2" />
        </div>
      </div>
      <div class="flex justify-end gap-3 pt-2">
        <button type="button" class="btn-secondary" @click="$emit('close')">Cancelar</button>
        <button type="submit" class="btn-primary" :disabled="saving">
          {{ saving ? 'Guardando...' : 'Guardar' }}
        </button>
      </div>
    </form>
  </BaseModal>
</template>
