<script setup>
import { ref, watch } from 'vue'
import { proceduresService } from '@/services/procedures.service'
import { inventoryService } from '@/services/inventory.service'
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
const linkedItems = ref([])
const allInventory = ref([])
const showInventoryDropdown = ref(false)
const selectedInventory = ref(null)
const selectedQty = ref(1)

watch(() => props.show, async (v) => {
  if (v) {
    if (props.procedure) {
      form.value = {
        name:         props.procedure.name || '',
        description:  props.procedure.description || '',
        category:     props.procedure.category || 'atencion_domicilio',
        duration_min: props.procedure.duration_min || 30,
        base_price:   props.procedure.base_price || 0,
      }
      const linked = await proceduresService.getLinkedInventory(props.procedure.id)
      linkedItems.value = linked.map(l => ({
        inventory_id: l.inventory.id,
        name:         l.inventory.name,
        quantity:     l.quantity,
        unit:         l.inventory.unit,
      }))
    } else {
      form.value = { ...RESET_FORM }
      linkedItems.value = []
    }
    allInventory.value = await inventoryService.getAll()
    showInventoryDropdown.value = false
    selectedInventory.value = null
    selectedQty.value = 1
  } else {
    form.value = { ...RESET_FORM }
    linkedItems.value = []
  }
})

function addInventoryItem() {
  if (!selectedInventory.value) return
  if (linkedItems.value.some(i => i.inventory_id === selectedInventory.value.id)) {
    addToast('Este insumo ya está vinculado', 'warning')
    return
  }
  linkedItems.value.push({
    inventory_id: selectedInventory.value.id,
    name:          selectedInventory.value.name,
    quantity:      selectedQty.value,
    unit:          selectedInventory.value.unit,
  })
  selectedInventory.value = null
  selectedQty.value = 1
  showInventoryDropdown.value = false
}

function removeInventoryItem(inventoryId) {
  linkedItems.value = linkedItems.value.filter(i => i.inventory_id !== inventoryId)
}

async function save() {
  saving.value = true
  try {
    const payload = { ...form.value, active: true }
    if (props.procedure?.id) payload.id = props.procedure.id
    const saved = await proceduresService.upsert(payload)
    await proceduresService.saveLinkedInventory(saved.id, linkedItems.value)
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

      <!-- Insumos vinculados -->
      <div class="border-t border-slate-700 pt-4">
        <div class="flex items-center justify-between mb-3">
          <h4 class="text-sm font-semibold text-slate-300">Insumos requeridos</h4>
          <button type="button" @click="showInventoryDropdown = !showInventoryDropdown"
            class="text-xs text-brand-400 hover:text-brand-300">
            + Agregar insumo
          </button>
        </div>

        <!-- Dropdown agregar -->
        <div v-if="showInventoryDropdown" class="flex gap-2 mb-3 p-3 bg-slate-800/60 rounded-lg">
          <select v-model="selectedInventory" class="input-base flex-1 text-sm">
            <option :value="null" disabled>Selecciona insumo</option>
            <option v-for="item in allInventory" :key="item.id" :value="item">
              {{ item.name }} ({{ item.stock }} {{ item.unit }})
            </option>
          </select>
          <input v-model.number="selectedQty" type="number" min="1" class="input-base w-20 text-sm" placeholder="Cant." />
          <button type="button" @click="addInventoryItem" class="btn-secondary text-sm">Agregar</button>
          <button type="button" @click="showInventoryDropdown = false" class="btn-ghost text-sm">✕</button>
        </div>

        <!-- Lista vinculada -->
        <div v-if="linkedItems.length === 0" class="text-xs text-slate-500 py-2">
          No hay insumos vinculados
        </div>
        <div v-else class="space-y-2">
          <div v-for="item in linkedItems" :key="item.inventory_id"
            class="flex items-center justify-between p-2 bg-slate-800/40 rounded-lg text-sm">
            <span class="text-slate-300">{{ item.name }}</span>
            <div class="flex items-center gap-2">
              <span class="text-slate-400">{{ item.quantity }} {{ item.unit }}</span>
              <button type="button" @click="removeInventoryItem(item.inventory_id)"
                class="text-red-400 hover:text-red-300 text-xs">✕</button>
            </div>
          </div>
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
