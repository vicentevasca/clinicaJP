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

function animateStep() {
  if (prefersReducedMotion) return
  gsap.from('.card', { opacity: 0, x: 16, duration: 0.25 })
}

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

function next() { if (validate()) { step.value++; animateStep() } }
function prev() { if (step.value > 1) { step.value--; animateStep() } }

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
  <div class="min-h-screen pt-20 pb-12 px-4" style="background-color: var(--bg-primary);">
    <div class="w-full max-w-lg mx-auto">

      <!-- ── Header ──────────────────────────────────────── -->
      <div class="text-center mb-8 animate-in">
        <!-- Logo / paw -->
        <div class="w-14 h-14 rounded-2xl flex items-center justify-center text-2xl mx-auto mb-4"
          style="background-color: var(--brand-alpha); border: 1px solid var(--border-color);">🐾</div>

        <h1 class="text-3xl font-bold tracking-tight mb-1" style="color: var(--text-primary);">
          Solicitar visita
        </h1>
        <p class="text-sm" style="color: var(--text-muted);">
          Completa el formulario y te contactamos en menos de 2 horas
        </p>

        <!-- Step pills -->
        <div class="flex items-center justify-center gap-2 mt-6">
          <template v-for="i in TOTAL_STEPS" :key="i">
            <!-- Step circle -->
            <div
              class="w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold transition-all duration-300 flex-shrink-0"
              :style="
                i < step
                  ? 'background-color: var(--brand-alpha); border: 2px solid var(--btn-primary-bg); color: var(--btn-primary-bg);'
                  : i === step
                    ? 'background-color: var(--btn-primary-bg); border: 2px solid var(--btn-primary-bg); color: #ffffff;'
                    : 'background-color: transparent; border: 2px solid var(--step-inactive-bg); color: var(--step-inactive-text);'
              "
            >
              <!-- Completed step: checkmark -->
              <svg v-if="i < step" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12" />
              </svg>
              <span v-else>{{ i }}</span>
            </div>

            <!-- Connector line between steps -->
            <div
              v-if="i < TOTAL_STEPS"
              class="flex-1 h-0.5 rounded-full transition-all duration-300 max-w-[2.5rem]"
              :style="i < step ? 'background-color: var(--btn-primary-bg);' : 'background-color: var(--step-inactive-bg);'"
            />
          </template>
        </div>

        <p class="text-xs mt-2 font-medium" style="color: var(--text-muted);">Paso {{ step }} de {{ TOTAL_STEPS }}</p>
      </div>

      <!-- ── Form card ──────────────────────────────────── -->
      <div :key="step" class="card p-6 space-y-5">

        <!-- ── Paso 1: Sobre ti ── -->
        <template v-if="step === 1">
          <div class="flex items-center gap-2.5 mb-1">
            <div class="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0"
              style="background-color: var(--brand-alpha);">
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                :style="{ color: 'var(--btn-primary-bg)' }">
                <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2M12 11a4 4 0 100-8 4 4 0 000 8z"/>
              </svg>
            </div>
            <div>
              <h2 class="text-lg font-bold" style="color: var(--text-primary);">Sobre ti</h2>
              <p class="text-xs" style="color: var(--text-muted);">Tus datos de contacto y ubicación</p>
            </div>
          </div>

          <BaseInput v-model="form.client_name"  label="Nombre completo" required :error="errors.client_name" />
          <BaseInput v-model="form.client_phone" label="Teléfono" placeholder="+569..." required :error="errors.client_phone" />
          <BaseInput v-model="form.client_email" label="Email (opcional)" type="email" />
          <BaseInput v-model="form.region"   label="Región"   required :error="errors.region" />
          <BaseInput v-model="form.comuna"   label="Comuna"   required :error="errors.comuna" />
          <BaseInput v-model="form.address"  label="Dirección" required :error="errors.address" />
        </template>

        <!-- ── Paso 2: Tu mascota ── -->
        <template v-else-if="step === 2">
          <div class="flex items-center gap-2.5 mb-1">
            <div class="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0"
              style="background-color: var(--brand-alpha);">
              <span style="font-size: 1rem; line-height: 1;">🐾</span>
            </div>
            <div>
              <h2 class="text-lg font-bold" style="color: var(--text-primary);">Tu mascota</h2>
              <p class="text-xs" style="color: var(--text-muted);">Datos del animal que recibirá la atención</p>
            </div>
          </div>

          <BaseInput  v-model="form.animal_name"    label="Nombre del animal" required :error="errors.animal_name" />
          <BaseSelect v-model="form.animal_species" label="Especie" required :options="ANIMAL_SPECIES" :error="errors.animal_species" />
          <BaseInput  v-model="form.animal_breed"   label="Raza (opcional)" />
          <BaseSelect v-model="form.animal_sex" label="Sexo"
            :options="[{value:'macho',label:'Macho'},{value:'hembra',label:'Hembra'},{value:'desconocido',label:'Desconocido'}]" />
        </template>

        <!-- ── Paso 3: ¿Qué necesitas? ── -->
        <template v-else-if="step === 3">
          <div class="flex items-center gap-2.5 mb-1">
            <div class="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0"
              style="background-color: var(--brand-alpha);">
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                :style="{ color: 'var(--btn-primary-bg)' }">
                <path d="M22 12h-4l-3 9L9 3l-3 9H2"/>
              </svg>
            </div>
            <div>
              <h2 class="text-lg font-bold" style="color: var(--text-primary);">¿Qué necesitas?</h2>
              <p class="text-xs" style="color: var(--text-muted);">Cuéntanos sobre el servicio que buscas</p>
            </div>
          </div>

          <BaseSelect v-model="form.service_type" label="Tipo de servicio" required :options="SERVICE_TYPES" :error="errors.service_type" />
          <div>
            <label class="label-base">
              Descripción del caso
              <span style="color: var(--text-error);">*</span>
            </label>
            <textarea
              v-model="form.description"
              rows="4"
              class="input-base resize-none"
              placeholder="Describe el caso con al menos 20 caracteres..."
            />
            <p v-if="errors.description" class="mt-1 text-xs" style="color: var(--text-error);">{{ errors.description }}</p>
          </div>
          <BaseSelect v-model="form.priority" label="Urgencia"
            :options="[{value:'normal',label:'Normal'},{value:'urgent',label:'Urgente'}]" />
        </template>

        <!-- ── Paso 4: Confirmación ── -->
        <template v-else>
          <div class="flex items-center gap-2.5 mb-1">
            <div class="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0"
              style="background-color: var(--brand-alpha);">
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                :style="{ color: 'var(--btn-primary-bg)' }">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
            </div>
            <div>
              <h2 class="text-lg font-bold" style="color: var(--text-primary);">Confirmar solicitud</h2>
              <p class="text-xs" style="color: var(--text-muted);">Revisa los datos antes de enviar</p>
            </div>
          </div>

          <div class="space-y-3 text-sm">
            <!-- Personal data -->
            <div class="rounded-xl p-4 space-y-2"
              style="background-color: var(--brand-alpha); border: 1px solid var(--border-color);">
              <p class="text-xs font-semibold uppercase tracking-wider mb-2" style="color: var(--btn-primary-bg);">
                Datos personales
              </p>
              <div class="grid grid-cols-[auto_1fr] gap-x-3 gap-y-1.5">
                <span style="color: var(--text-muted);">Nombre</span>
                <span class="font-medium" style="color: var(--text-primary);">{{ form.client_name }}</span>
                <span style="color: var(--text-muted);">Teléfono</span>
                <span class="font-medium" style="color: var(--text-primary);">{{ form.client_phone }}</span>
                <span v-if="form.client_email" style="color: var(--text-muted);">Email</span>
                <span v-if="form.client_email" class="font-medium" style="color: var(--text-primary);">{{ form.client_email }}</span>
                <span style="color: var(--text-muted);">Dirección</span>
                <span class="font-medium" style="color: var(--text-primary);">{{ form.address }}, {{ form.comuna }}, {{ form.region }}</span>
              </div>
            </div>

            <!-- Animal data -->
            <div class="rounded-xl p-4 space-y-2"
              style="background-color: var(--brand-alpha); border: 1px solid var(--border-color);">
              <p class="text-xs font-semibold uppercase tracking-wider mb-2" style="color: var(--btn-primary-bg);">
                Mascota
              </p>
              <div class="grid grid-cols-[auto_1fr] gap-x-3 gap-y-1.5">
                <span style="color: var(--text-muted);">Nombre</span>
                <span class="font-medium" style="color: var(--text-primary);">{{ form.animal_name }}</span>
                <span style="color: var(--text-muted);">Especie</span>
                <span class="font-medium capitalize" style="color: var(--text-primary);">{{ form.animal_species }}</span>
                <template v-if="form.animal_breed">
                  <span style="color: var(--text-muted);">Raza</span>
                  <span class="font-medium" style="color: var(--text-primary);">{{ form.animal_breed }}</span>
                </template>
                <template v-if="form.animal_sex">
                  <span style="color: var(--text-muted);">Sexo</span>
                  <span class="font-medium capitalize" style="color: var(--text-primary);">{{ form.animal_sex }}</span>
                </template>
              </div>
            </div>

            <!-- Service data -->
            <div class="rounded-xl p-4 space-y-2"
              style="background-color: var(--brand-alpha); border: 1px solid var(--border-color);">
              <p class="text-xs font-semibold uppercase tracking-wider mb-2" style="color: var(--btn-primary-bg);">
                Solicitud
              </p>
              <div class="grid grid-cols-[auto_1fr] gap-x-3 gap-y-1.5">
                <span style="color: var(--text-muted);">Servicio</span>
                <span class="font-medium capitalize" style="color: var(--text-primary);">{{ form.service_type?.replace(/_/g, ' ') }}</span>
                <span style="color: var(--text-muted);">Urgencia</span>
                <span class="font-medium capitalize" style="color: var(--text-primary);">{{ form.priority }}</span>
                <span style="color: var(--text-muted);">Descripción</span>
                <span class="font-medium" style="color: var(--text-primary);">{{ form.description }}</span>
              </div>
            </div>
          </div>

          <p v-if="errors.submit" class="text-sm mt-1 text-center" style="color: var(--text-error);">
            {{ errors.submit }}
          </p>
        </template>

        <!-- ── Navigation buttons ── -->
        <div class="flex gap-3 pt-1">
          <button
            v-if="step > 1"
            type="button"
            class="btn-secondary px-5 py-3"
            @click="prev"
          >
            ← Atrás
          </button>

          <button
            v-if="step < TOTAL_STEPS"
            type="button"
            class="btn-primary flex-1 py-3"
            @click="next"
          >
            Continuar →
          </button>

          <button
            v-else
            type="button"
            class="btn-primary flex-1 py-3"
            :disabled="loading"
            @click="submit"
          >
            <span v-if="loading" class="spinner" aria-hidden="true" />
            <span>{{ loading ? 'Enviando…' : 'Enviar solicitud' }}</span>
          </button>
        </div>

      </div>
      <!-- end card -->

    </div>
  </div>
</template>
