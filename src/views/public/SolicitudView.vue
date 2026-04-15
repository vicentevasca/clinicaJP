<script setup>
import { ref, onMounted } from 'vue'
import BaseInput  from '@/components/ui/BaseInput.vue'
import BaseSelect from '@/components/ui/BaseSelect.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { ANIMAL_SPECIES, SERVICE_TYPES } from '@/utils/constants'
import { normalizePhone, isValidChilePhone } from '@/utils/validators'
import { useRouter } from 'vue-router'
import { gsap } from 'gsap'

const router  = useRouter()
const step    = ref(1)
const loading = ref(false)
const TOTAL_STEPS = 4

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

const form = ref({
  client_name: '', client_phone: '', client_email: '',
  region: '', comuna: '', address: '',
  animal_name: '', animal_species: '', animal_breed: '', animal_sex: '',
  service_type: '', description: '', priority: 'normal',
})
const errors = ref({})

onMounted(() => {
  if (prefersReducedMotion) return
  gsap.from('.animate-in', { opacity: 0, y: 20, stagger: 0.12, duration: 0.5, delay: 0.1 })
})

function validate() {
  errors.value = {}
  if (step.value === 1) {
    if (!form.value.client_name)  errors.value.client_name = 'Nombre requerido'
    if (!form.value.client_phone || !isValidChilePhone(form.value.client_phone))
      errors.value.client_phone = 'Teléfono inválido (+56...)'
    if (!form.value.region)  errors.value.region  = 'Región requerida'
    if (!form.value.comuna)  errors.value.comuna  = 'Comuna requerida'
    if (!form.value.address) errors.value.address = 'Dirección requerida'
  }
  if (step.value === 2) {
    if (!form.value.animal_name)    errors.value.animal_name    = 'Nombre requerido'
    if (!form.value.animal_species) errors.value.animal_species = 'Especie requerida'
  }
  if (step.value === 3) {
    if (!form.value.service_type)   errors.value.service_type = 'Servicio requerido'
    if (!form.value.description || form.value.description.length < 20)
      errors.value.description = 'Mínimo 20 caracteres'
  }
  return Object.keys(errors.value).length === 0
}

function next() { if (validate()) step.value++ }
function prev() { if (step.value > 1) step.value-- }

async function submit() {
  if (!validate()) return
  loading.value = true
  try {
    const payload = {
      ...form.value,
      client_phone: normalizePhone(form.value.client_phone)
    }
    const res = await fetch(
      `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/create-lead`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': import.meta.env.VITE_SUPABASE_ANON_KEY,
        },
        body: JSON.stringify(payload),
      }
    )
    if (!res.ok) throw new Error('Error al enviar')
    router.push('/confirmacion')
  } catch (e) {
    errors.value.submit = 'Error al enviar. Intenta nuevamente.'
  } finally {
    loading.value = false
  }
}
</script>
<template>
  <div class="min-h-screen bg-[var(--bg-primary)] flex items-center justify-center px-4 py-12">
    <div class="w-full max-w-lg">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-semibold text-[var(--text-primary)]">Solicitar visita</h1>
        <div class="flex justify-center gap-2 mt-4">
          <div v-for="i in TOTAL_STEPS" :key="i"
            class="h-1.5 rounded-full transition-all duration-300"
            :class="[i <= step ? 'bg-[var(--step-active-bg)] w-8' : 'bg-[var(--step-inactive-bg)] w-4']" />
        </div>
        <p class="text-[var(--text-muted)] text-sm mt-2">Paso {{ step }} de {{ TOTAL_STEPS }}</p>
      </div>

      <div class="card p-6 space-y-4">
        <!-- Paso 1 -->
        <template v-if="step === 1">
          <h2 class="text-lg font-semibold text-[var(--text-primary)] mb-2">Sobre ti</h2>
          <BaseInput v-model="form.client_name"  label="Nombre completo" required :error="errors.client_name" />
          <BaseInput v-model="form.client_phone" label="Teléfono" placeholder="+569..." required :error="errors.client_phone" />
          <BaseInput v-model="form.client_email" label="Email" type="email" />
          <BaseInput v-model="form.region"   label="Región"   required :error="errors.region" />
          <BaseInput v-model="form.comuna"   label="Comuna"   required :error="errors.comuna" />
          <BaseInput v-model="form.address"  label="Dirección" required :error="errors.address" />
        </template>

        <!-- Paso 2 -->
        <template v-else-if="step === 2">
          <h2 class="text-lg font-semibold text-[var(--text-primary)] mb-2">Tu mascota</h2>
          <BaseInput  v-model="form.animal_name"    label="Nombre del animal" required :error="errors.animal_name" />
          <BaseSelect v-model="form.animal_species" label="Especie" required :options="ANIMAL_SPECIES" :error="errors.animal_species" />
          <BaseInput  v-model="form.animal_breed"   label="Raza (opcional)" />
          <BaseSelect v-model="form.animal_sex" label="Sexo"
            :options="[{value:'macho',label:'Macho'},{value:'hembra',label:'Hembra'},{value:'desconocido',label:'Desconocido'}]" />
        </template>

        <!-- Paso 3 -->
        <template v-else-if="step === 3">
          <h2 class="text-lg font-semibold text-[var(--text-primary)] mb-2">¿Qué necesitas?</h2>
          <BaseSelect v-model="form.service_type" label="Tipo de servicio" required :options="SERVICE_TYPES" :error="errors.service_type" />
          <div>
            <label class="label-base">Descripción del caso <span style="color: var(--text-error)">*</span></label>
            <textarea v-model="form.description" rows="4" class="input-base resize-none"
              placeholder="Describe el caso con al menos 20 caracteres..." />
            <p v-if="errors.description" class="mt-1 text-xs" style="color: var(--text-error)">{{ errors.description }}</p>
          </div>
          <BaseSelect v-model="form.priority" label="Urgencia"
            :options="[{value:'normal',label:'Normal'},{value:'urgent',label:'Urgente'}]" />
        </template>

        <!-- Paso 4 -->
        <template v-else>
          <h2 class="text-lg font-semibold text-[var(--text-primary)] mb-2">Confirmar solicitud</h2>
          <div class="space-y-3 text-sm">
            <div class="bg-[var(--brand-alpha)] rounded-lg p-3 space-y-1">
              <p class="text-[var(--text-muted)] text-xs uppercase tracking-wider mb-2">Datos personales</p>
              <p><span class="text-[var(--text-secondary)]">Nombre:</span> <span class="text-[var(--text-primary)]">{{ form.client_name }}</span></p>
              <p><span class="text-[var(--text-secondary)]">Teléfono:</span> <span class="text-[var(--text-primary)]">{{ form.client_phone }}</span></p>
              <p><span class="text-[var(--text-secondary)]">Dirección:</span> <span class="text-[var(--text-primary)]">{{ form.comuna }}, {{ form.region }}</span></p>
            </div>
            <div class="bg-[var(--brand-alpha)] rounded-lg p-3 space-y-1">
              <p class="text-[var(--text-muted)] text-xs uppercase tracking-wider mb-2">Mascota</p>
              <p><span class="text-[var(--text-secondary)]">Nombre:</span> <span class="text-[var(--text-primary)]">{{ form.animal_name }}</span></p>
              <p><span class="text-[var(--text-secondary)]">Especie:</span> <span class="text-[var(--text-primary)] capitalize">{{ form.animal_species }}</span></p>
            </div>
            <div class="bg-[var(--brand-alpha)] rounded-lg p-3 space-y-1">
              <p class="text-[var(--text-muted)] text-xs uppercase tracking-wider mb-2">Solicitud</p>
              <p><span class="text-[var(--text-secondary)]">Servicio:</span> <span class="text-[var(--text-primary)] capitalize">{{ form.service_type?.replace('_',' ') }}</span></p>
              <p><span class="text-[var(--text-secondary)]">Descripción:</span> <span class="text-[var(--text-primary)]">{{ form.description }}</span></p>
            </div>
          </div>
          <p v-if="errors.submit" class="text-sm" style="color: var(--text-error)">{{ errors.submit }}</p>
        </template>

        <!-- Acciones -->
        <div class="flex gap-3 pt-2">
          <BaseButton v-if="step > 1" variant="secondary" @click="prev">Atrás</BaseButton>
          <BaseButton v-if="step < TOTAL_STEPS" class="flex-1" @click="next">Continuar →</BaseButton>
          <BaseButton v-else class="flex-1" :loading="loading" @click="submit">Enviar solicitud</BaseButton>
        </div>
      </div>
    </div>
  </div>
</template>
