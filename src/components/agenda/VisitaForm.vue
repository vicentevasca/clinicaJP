<script setup>
import { ref, watch, computed } from 'vue'
import { visitsService } from '@/services/visits.service'
import { patientsService } from '@/services/patients.service'
import { useToast } from '@/composables/useToast'
import { useAuthStore } from '@/stores/auth'
import { storeToRefs } from 'pinia'
import BaseModal from '@/components/ui/BaseModal.vue'

const props = defineProps({
  show:   { type: Boolean, default: false },
  visit:  { type: Object, default: null },
  leadId: { type: String, default: null },
})
const emit = defineEmits(['close', 'saved'])

const { addToast } = useToast()
const authStore = useAuthStore()
const { profile } = storeToRefs(authStore)

const form = ref({
  client_id:    '',
  animal_id:    '',
  assigned_to:  '',
  scheduled_at: '',
  duration_min: 60,
  address:      '',
  notes:        '',
})
const saving  = ref(false)
const clients = ref([])
const animals = ref([])

const filteredAnimals = computed(() =>
  form.value.client_id
    ? animals.value.filter(a => a.client_id === form.value.client_id)
    : []
)

watch(() => props.show, async (v) => {
  if (!v) return
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
      client_id:    '',
      animal_id:    '',
      assigned_to:  profile.value?.id ?? '',
      scheduled_at: new Date().toISOString().slice(0, 16),
      duration_min: 60,
      address:      '',
      notes:        '',
    }
    // Cargar clientes y animales para el formulario de creación
    try {
      const [clientsData, animalsData] = await Promise.all([
        patientsService.getClients(),
        patientsService.getAnimals(),
      ])
      clients.value  = clientsData
      animals.value = animalsData
    } catch (e) {
      addToast('Error cargando datos: ' + e.message, 'error')
    }
  }
})

watch(() => form.value.client_id, () => {
  form.value.animal_id = ''
  // Auto-completar dirección desde el cliente seleccionado
  const client = clients.value.find(c => c.id === form.value.client_id)
  if (client?.address) form.value.address = client.address
})

async function save() {
  if (!props.visit) {
    if (!form.value.client_id || !form.value.animal_id || !form.value.assigned_to) {
      addToast('Completa los campos obligatorios', 'error')
      return
    }
  }
  saving.value = true
  try {
    if (props.visit) {
      await visitsService.update(props.visit.id, {
        scheduled_at: form.value.scheduled_at,
        duration_min: form.value.duration_min,
        address:      form.value.address,
        notes:        form.value.notes,
      })
    } else {
      await visitsService.create({
        lead_id:      props.leadId || null,
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

        <!-- CREATE ONLY: cliente -->
        <template v-if="!visit">
          <div>
            <label class="label-base">Cliente *</label>
            <select v-model="form.client_id" class="input-base" required>
              <option value="">Seleccionar cliente</option>
              <option v-for="c in clients" :key="c.id" :value="c.id">{{ c.name }} — {{ c.phone }}</option>
            </select>
          </div>

          <div>
            <label class="label-base">Animal *</label>
            <select v-model="form.animal_id" class="input-base" required :disabled="!form.client_id">
              <option value="">{{ form.client_id ? 'Seleccionar animal' : 'Selecciona cliente primero' }}</option>
              <option v-for="a in filteredAnimals" :key="a.id" :value="a.id">
                {{ a.name }} ({{ a.species }})
              </option>
            </select>
          </div>
        </template>

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
