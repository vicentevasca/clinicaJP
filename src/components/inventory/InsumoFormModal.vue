<script setup>
import { ref, watch } from 'vue'
import { inventoryService } from '@/services/inventory.service'
import { useToast } from '@/composables/useToast'
import BaseModal from '@/components/ui/BaseModal.vue'

const props = defineProps({
  show:  { type: Boolean, default: false },
  item:  { type: Object, default: null },
})
const emit = defineEmits(['close', 'saved'])

const { addToast } = useToast()

const CATEGORIES = ['vacuna', 'farmaco', 'insumo', 'herramienta']

const form = ref({
  name:         '',
  description:  '',
  category:     'insumo',
  stock:        0,
  min_stock:   0,
  unit:        'unidad',
  cost_per_unit: 0,
  supplier_name: '',
  supplier_phone: '',
})

const saving = ref(false)

watch(() => props.show, (v) => {
  if (v) {
    if (props.item) {
      form.value = {
        name:         props.item.name || '',
        description:  props.item.description || '',
        category:     props.item.category || 'insumo',
        stock:        props.item.stock || 0,
        min_stock:   props.item.min_stock || 0,
        unit:         props.item.unit || 'unidad',
        cost_per_unit: props.item.cost_per_unit || 0,
        supplier_name: props.item.supplier_name || '',
        supplier_phone: props.item.supplier_phone || '',
      }
    } else {
      form.value = { name:'', description:'', category:'insumo', stock:0, min_stock:0, unit:'unidad', cost_per_unit:0, supplier_name:'', supplier_phone:'' }
    }
  }
})

async function save() {
  saving.value = true
  try {
    const payload = { ...form.value, active: true }
    if (props.item?.id) {
      payload.id = props.item.id
    }
    await inventoryService.upsert(payload)
    addToast(props.item ? 'Insumo actualizado' : 'Insumo creado', 'success')
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
  <BaseModal :show="show" :title="item ? 'Editar Insumo' : 'Nuevo Insumo'" size="lg" @close="$emit('close')">
    <form @submit.prevent="save" class="space-y-4">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="label-base">Nombre *</label>
          <input v-model="form.name" type="text" class="input-base" required />
        </div>
        <div>
          <label class="label-base">Categoría</label>
          <select v-model="form.category" class="input-base">
            <option v-for="c in CATEGORIES" :key="c" :value="c" class="capitalize">{{ c }}</option>
          </select>
        </div>
        <div>
          <label class="label-base">Stock actual</label>
          <input v-model.number="form.stock" type="number" step="0.01" class="input-base" />
        </div>
        <div>
          <label class="label-base">Stock mínimo (alerta)</label>
          <input v-model.number="form.min_stock" type="number" step="0.01" class="input-base" />
        </div>
        <div>
          <label class="label-base">Unidad</label>
          <input v-model="form.unit" type="text" class="input-base" placeholder="unidad, ml, mg, caja..." />
        </div>
        <div>
          <label class="label-base">Costo unitario</label>
          <input v-model.number="form.cost_per_unit" type="number" step="0.01" class="input-base" />
        </div>
        <div>
          <label class="label-base">Proveedor</label>
          <input v-model="form.supplier_name" type="text" class="input-base" />
        </div>
        <div>
          <label class="label-base">Teléfono proveedor</label>
          <input v-model="form.supplier_phone" type="text" class="input-base" />
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
