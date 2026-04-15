<script setup>
import { ref, watch } from 'vue'
import { leadsService } from '@/services/leads.service'
import { supabase } from '@/services/supabase'
import { useToast } from '@/composables/useToast'
import BaseModal from '@/components/ui/BaseModal.vue'
import BaseSelect from '@/components/ui/BaseSelect.vue'
import { SERVICE_TYPES, PRIORITY_LEVELS, ANIMAL_SPECIES } from '@/utils/constants'

const props = defineProps({
  show:   { type: Boolean, default: false },
  lead:   { type: Object, default: null },   // null = crear
})
const emit = defineEmits(['close', 'saved'])

const { addToast } = useToast()

const RESET_FORM = {
  client_name: '', client_phone: '', client_email: '',
  region: '', comuna: '', address: '',
  animal_name: '', animal_species: '', animal_breed: '', animal_sex: '',
  service_type: '', description: '', priority: 'normal',
}

const form = ref({ ...RESET_FORM })
const saving = ref(false)

watch(() => props.show, (v) => {
  if (v) {
    if (props.lead) {
      form.value = {
        client_name:    props.lead.client?.name || '',
        client_phone:   props.lead.client?.phone || '',
        client_email:   props.lead.client?.email || '',
        region:         props.lead.client?.region || '',
        comuna:         props.lead.client?.comuna || '',
        address:        props.lead.client?.address || '',
        animal_name:    props.lead.animal?.name || '',
        animal_species: props.lead.animal?.species || '',
        animal_breed:   props.lead.animal?.breed || '',
        animal_sex:     props.lead.animal?.sex || '',
        service_type:   props.lead.service_type || '',
        description:    props.lead.description || '',
        priority:       props.lead.priority || 'normal',
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
    if (!props.lead) {
      // Crear lead via Edge Function (crea cliente + animal + lead)
      const { data: { session } } = await supabase.auth.getSession()
      const { data, error } = await supabase.functions.invoke('create-lead', {
        body: {
          client_name:    form.value.client_name,
          client_phone:   form.value.client_phone,
          client_email:   form.value.client_email,
          region:         form.value.region,
          comuna:         form.value.comuna,
          address:        form.value.address,
          animal_name:    form.value.animal_name,
          animal_species: form.value.animal_species,
          animal_breed:   form.value.animal_breed,
          animal_sex:     form.value.animal_sex,
          service_type:   form.value.service_type,
          description:    form.value.description,
          priority:       form.value.priority,
        },
        headers: { Authorization: `Bearer ${session?.access_token}` },
      })
      if (error) throw new Error(error.message || 'Error al crear lead')
      addToast('Lead guardado', 'success')
    } else {
      // Actualizar lead existente via servicio
      await leadsService.update(props.lead.id, {
        service_type: form.value.service_type,
        description:  form.value.description,
        priority:     form.value.priority,
      })
      addToast('Lead actualizado', 'success')
    }
    emit('saved')
    emit('close')
  } catch (e) {
    addToast('Error al guardar: ' + e.message, 'error')
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <BaseModal :show="show" :title="lead ? 'Editar Lead' : 'Nuevo Lead'" size="lg" @close="$emit('close')">
    <form @submit.prevent="save" class="space-y-4">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label class="label-base">Nombre cliente *</label>
          <input v-model="form.client_name" type="text" class="input-base" required />
        </div>
        <div>
          <label class="label-base">Teléfono *</label>
          <input v-model="form.client_phone" type="text" class="input-base" placeholder="+56..." required />
        </div>
        <div>
          <label class="label-base">Email</label>
          <input v-model="form.client_email" type="email" class="input-base" />
        </div>
        <div>
          <label class="label-base">Región</label>
          <input v-model="form.region" type="text" class="input-base" />
        </div>
        <div>
          <label class="label-base">Comuna</label>
          <input v-model="form.comuna" type="text" class="input-base" />
        </div>
        <div class="md:col-span-2">
          <label class="label-base">Dirección</label>
          <input v-model="form.address" type="text" class="input-base" />
        </div>
        <div>
          <label class="label-base">Nombre animal *</label>
          <input v-model="form.animal_name" type="text" class="input-base" required />
        </div>
        <BaseSelect label="Especie" v-model="form.animal_species" :options="ANIMAL_SPECIES" />
        <div>
          <label class="label-base">Raza</label>
          <input v-model="form.animal_breed" type="text" class="input-base" />
        </div>
        <BaseSelect label="Sexo" v-model="form.animal_sex" :options="[{value:'macho',label:'Macho'},{value:'hembra',label:'Hembra'},{value:'desconocido',label:'Desconocido'}]" />
        <BaseSelect label="Servicio" v-model="form.service_type" :options="SERVICE_TYPES" />
        <BaseSelect label="Prioridad" v-model="form.priority" :options="PRIORITY_LEVELS" />
        <div class="md:col-span-2">
          <label class="label-base">Descripción</label>
          <textarea v-model="form.description" class="input-base" rows="3" />
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
