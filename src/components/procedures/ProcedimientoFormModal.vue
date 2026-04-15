<script setup>
import { ref, watch } from 'vue'
import { proceduresService } from '@/services/procedures.service'
import { useToast } from '@/composables/useToast'
import BaseModal from '@/components/ui/BaseModal.vue'

const props = defineProps({
  show:      { type: Boolean, default: false },
  procedure: { type: Object, default: null },
})
const emit = defineEmits(['close', 'saved'])

const { addToast } = useToast()

const CATEGORIES = ['vacunacion','desparasitacion','chequeo','receta','corte_pelo','atencion_domicilio','otro']

const RESET_FORM = {
  name: '', description: '', category: 'atencion_domicilio', duration_min: 30, base_price: 0,
}

const form = ref({ ...RESET_FORM })
const saving    = ref(false)

watch(() => props.show, (v) => {
  if (v) {
    if (props.procedure) {
      form.value = {
        name:         props.procedure.name || '',
        description:  props.procedure.description || '',
        category:     props.procedure.category || 'atencion_domicilio',
        duration_min: props.procedure.duration_min || 30,
        base_price:   props.procedure.base_price || 0,
      }
    } else {
      form.value = { ...RESET_FORM }
    }
  } else {
    form.value = { ...RESET_FORM }
  }
})

async function save() {
  saving.value = true
  try {
    const payload = { ...form.value, active: true }
    if (props.procedure?.id) payload.id = props.procedure.id
    await proceduresService.upsert(payload)
    addToast(props.procedure ? 'Procedimiento actualizado' : 'Procedimiento creado', 'success')
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
  <BaseModal :show="show" :title="procedure ? 'Editar Procedimiento' : 'Nuevo Procedimiento'" size="lg" @close="$emit('close')">
    <form @submit.prevent="save" class="space-y-4">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="label-base">Nombre *</label>
          <input v-model="form.name" type="text" class="input-base" required />
        </div>
        <div>
          <label class="label-base">Categoría</label>
          <select v-model="form.category" class="input-base">
            <option v-for="c in CATEGORIES" :key="c" :value="c">{{ c.replace('_',' ') }}</option>
          </select>
        </div>
        <div>
          <label class="label-base">Duración (min)</label>
          <input v-model.number="form.duration_min" type="number" class="input-base" min="5" step="5" />
        </div>
        <div>
          <label class="label-base">Precio base (CLP)</label>
          <input v-model.number="form.base_price" type="number" class="input-base" min="0" />
        </div>
        <div class="md:col-span-2">
          <label class="label-base">Descripción</label>
          <textarea v-model="form.description" class="input-base" rows="2" />
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
