<script setup>
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { gsap } from 'gsap'

const heroRef = ref(null)
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

onMounted(() => {
  if (prefersReducedMotion) return
  const tl = gsap.timeline()
  tl.from('.hero-animate', { opacity: 0, y: 28, stagger: 0.12, duration: 0.6, delay: 0.2 })
    .from('.section-animate', { opacity: 0, y: 18, stagger: 0.08, duration: 0.5 }, '-=0.3')
})

const services = [
  {
    title: 'Vacunación',
    desc: 'Esquemas completos para perros, gatos y más. Certificados oficiales.',
    svgPath: 'M19 3H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2zm-1 11h-4v4h-4v-4H6v-4h4V6h4v4h4v4z'
  },
  {
    title: 'Chequeo general',
    desc: 'Revisión completa del estado de salud de tu mascota a domicilio.',
    svgPath: 'M22 12h-4l-3 9L9 3l-3 9H2'
  },
  {
    title: 'Desparasitación',
    desc: 'Tratamientos internos y externos adaptados a cada etapa del animal.',
    svgPath: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z'
  },
  {
    title: 'Corte de pelo',
    desc: 'Baño, corte y limpieza de oídos. Tu mascota lista y feliz.',
    svgPath: 'M6 21c1.5-1.5 3-2 5-2s3.5.5 5 2M6 17c1.5-1.5 3-2 5-2s3.5.5 5 2M8 13c0 0 1-2 4-2s4 2 4 2M4 9c0 0 1.5-2 4-2s4 2 4 2M12 2v4M2 12h4M18 12h4'
  },
  {
    title: 'Recetas médicas',
    desc: 'Emitimos recetas válidas para cualquier farmacia veterinaria.',
    svgPath: 'M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6zm-1 2l5 5h-5V4zM9 13h6M9 17h6M9 9h2'
  },
  {
    title: 'Atención a domicilio',
    desc: 'El veterinario llega a tu casa. Sin estrés para tu mascota.',
    svgPath: 'M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z'
  }
]

const steps = [
  {
    num: '01',
    title: 'Llena el formulario',
    desc: 'Dinos qué necesita tu mascota y dónde estás. Tarda menos de 2 minutos.'
  },
  {
    num: '02',
    title: 'Te contactamos',
    desc: 'Confirmamos tu solicitud y coordinamos la mejor hora para visitarlos.'
  },
  {
    num: '03',
    title: 'Visitamos a tu mascota',
    desc: 'Llegamos a tu domicilio con todo lo necesario para la atención.'
  }
]

const benefits = [
  { title: 'Respuesta rápida', desc: 'Contactamos en menos de 2 horas hábiles' },
  { title: 'En tu hogar', desc: 'Tu mascota se atiende cómoda en su entorno' },
  { title: 'Veterinarios capacitados', desc: 'Técnicos con experiencia en atención domiciliaria' },
  { title: 'Seguimiento continuo', desc: 'Historial clínico digital de cada visita' },
  { title: 'Precios justos', desc: 'Sin costos ocultos, transparencia total' },
  { title: 'Insumos de calidad', desc: 'Solo medicamentos y productos certificados' }
]
</script>

<template>
  <div class="min-h-screen pt-16" style="background-color: var(--bg-primary);">

    <!-- Hero -->
    <section class="pt-24 pb-20 px-6" style="background-color: var(--bg-secondary);">
      <div class="max-w-4xl mx-auto text-center" ref="heroRef">
        <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full mb-6 hero-animate"
          style="background-color: var(--brand-alpha); border: 1px solid var(--border-color); color: var(--btn-primary-bg);">
          <span class="w-1.5 h-1.5 rounded-full animate-pulse" style="background-color: var(--btn-primary-bg);" aria-hidden="true" />
          Atención a domicilio en toda la región
        </div>
        <h1 class="text-4xl sm:text-5xl lg:text-6xl font-bold leading-none tracking-tight mb-6 hero-animate" style="color: var(--text-primary);">
          Veterinaria a domicilio<br />
          <span style="color: var(--btn-primary-bg);">sin complicaciones</span>
        </h1>
        <p class="text-lg sm:text-xl max-w-2xl mx-auto mb-10 leading-relaxed hero-animate" style="color: var(--text-secondary);">
          Llegamos hasta tu hogar para atender a tu mascota. Vacunas, chequeos, desparasitación y más — sin estrés para ella, sin complicaciones para ti.
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center hero-animate">
          <RouterLink to="/solicitar" class="btn-primary text-base px-8 py-3.5 shadow-md">
            Solicitar atención
          </RouterLink>
          <RouterLink to="/mi-mascota" class="btn-secondary text-base px-8 py-3.5">
            Mi Mascota
          </RouterLink>
        </div>

        <!-- Social proof bar -->
        <div class="mt-10 flex items-center justify-center gap-6 text-sm hero-animate">
          <div class="flex items-center gap-1.5">
            <span style="color: #eab308;">★★★★★</span>
            <span class="font-medium" style="color: var(--text-primary);">4.9/5</span>
            <span style="color: var(--text-muted);">(120 reseñas)</span>
          </div>
          <span style="color: var(--border-color);" class="hidden sm:block">·</span>
          <span class="font-medium" style="color: var(--text-secondary);">340+ mascotas atendidas</span>
          <span style="color: var(--border-color);" class="hidden sm:block">·</span>
          <span class="font-medium" style="color: var(--text-secondary);">Certificados oficiales</span>
        </div>
      </div>
    </section>

    <!-- Servicios -->
    <section id="servicios" class="py-20 px-6" style="background-color: var(--bg-card);">
      <div class="max-w-6xl mx-auto">
        <div class="text-center mb-14 section-animate">
          <h2 class="text-3xl font-bold mb-4 tracking-tight" style="color: var(--text-primary);">Servicios disponibles</h2>
          <p class="max-w-lg mx-auto text-lg" style="color: var(--text-muted);">Atención completa para tu mascota, directo desde la comodidad de tu hogar</p>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          <div v-for="(s, i) in services" :key="s.title"
            class="p-6 rounded-xl transition-all hover:-translate-y-0.5 section-animate"
            :class="i < 2 ? '' : ''"
            :style="i < 2 ? 'border: 2px solid var(--card-hover-border); background-color: var(--brand-alpha-hover);' : 'border: 1px solid var(--border-color); background-color: var(--bg-card);'">
            <span v-if="i === 0" class="inline-block px-2 py-0.5 text-xs rounded-full mb-3 font-semibold" style="background-color: var(--btn-primary-bg); color: white;">Más solicitado</span>
            <span v-if="i === 1" class="inline-block px-2 py-0.5 text-xs rounded-full mb-3 font-semibold" style="background-color: var(--brand-alpha); color: var(--btn-primary-bg); border: 1px solid var(--border-color);">Popular</span>
            <div class="w-10 h-10 rounded-xl flex items-center justify-center mb-4" style="background-color: var(--brand-alpha);">
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor" :style="{ color: 'var(--btn-primary-bg)' }">
                <path :d="s.svgPath"/>
              </svg>
            </div>
            <h3 class="text-lg font-semibold mb-2" style="color: var(--text-primary);">{{ s.title }}</h3>
            <p class="text-sm leading-relaxed" style="color: var(--text-secondary);">{{ s.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Cómo funciona -->
    <section id="como-funciona" class="py-20 px-6" style="background-color: var(--bg-secondary);">
      <div class="max-w-5xl mx-auto">
        <div class="text-center mb-14 section-animate">
          <h2 class="text-3xl font-bold mb-4 tracking-tight" style="color: var(--text-primary);">¿Cómo funciona?</h2>
          <p style="color: var(--text-muted);">Tres pasos simples para la atención de tu mascota</p>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div v-for="(step, i) in steps" :key="step.num"
            class="text-center section-animate relative">
            <div class="w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-5 shadow-md" style="background-color: var(--btn-primary-bg); box-shadow: 0 4px 12px var(--btn-primary-shadow);">
              <span class="text-xl font-bold text-white">{{ step.num }}</span>
            </div>
            <div v-if="i < 2" class="hidden md:block absolute top-7 left-[58%] w-[84%] border-t-2 border-dashed" style="border-color: var(--border-color);" />
            <h3 class="text-lg font-semibold mb-2" style="color: var(--text-primary);">{{ step.title }}</h3>
            <p class="text-sm leading-relaxed" style="color: var(--text-secondary);">{{ step.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Por qué elegirnos -->
    <section class="py-20 px-6" style="background-color: var(--bg-card);">
      <div class="max-w-6xl mx-auto">
        <div class="text-center mb-14 section-animate">
          <h2 class="text-3xl font-bold mb-4 tracking-tight" style="color: var(--text-primary);">¿Por qué elegirnos?</h2>
          <p style="color: var(--text-muted);">La mejor experiencia para ti y tu mascota</p>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          <div v-for="b in benefits" :key="b.title"
            class="flex items-start gap-4 p-5 rounded-xl section-animate"
            style="background-color: var(--bg-secondary); border: 1px solid var(--border-color);">
            <div class="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5" style="background-color: var(--brand-alpha);">
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" :style="{ color: 'var(--btn-primary-bg)' }">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
            </div>
            <div>
              <h3 class="font-semibold mb-1" style="color: var(--text-primary);">{{ b.title }}</h3>
              <p class="text-sm leading-relaxed" style="color: var(--text-secondary);">{{ b.desc }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Mi Mascota -->
    <section id="mi-mascota" class="py-20 px-6" style="background-color: var(--btn-primary-bg);">
      <div class="max-w-5xl mx-auto">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          <div class="section-animate">
            <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-sm font-semibold mb-4"
              style="background-color: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.2); color: rgba(255,255,255,0.9);">
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z"/><path d="M12 8v4l3 3"/></svg>
              Nuevo portal para clientes
            </div>
            <h2 class="text-3xl sm:text-4xl font-bold mb-4 leading-tight tracking-tight" style="color: white;">
              Consulta el historial<br />
              <span style="color: #fef08a;">de tu mascota</span> desde la web
            </h2>
            <p class="mb-6 leading-relaxed" style="color: var(--brand-alpha);">
              ¿Ya tienes mascota registrada con nosotros? Accede al portal <strong style="color: white; font-weight: 600;">Mi Mascota</strong> para ver el expediente clínico completo de tu compañero: diagnósticos, tratamientos, vacunas aplicadas y el historial de visitas a domicilio.
            </p>
            <ul class="space-y-3 mb-8">
              <li class="flex items-center gap-3 text-sm" style="color: var(--brand-alpha);">
                <svg class="w-4 h-4 flex-shrink-0" style="color: #fde047;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                Historial clínico completo y actualizado
              </li>
              <li class="flex items-center gap-3 text-sm" style="color: var(--brand-alpha);">
                <svg class="w-4 h-4 flex-shrink-0" style="color: #fde047;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                Acceso por RUT o teléfono (sin contraseña)
              </li>
              <li class="flex items-center gap-3 text-sm" style="color: var(--brand-alpha);">
                <svg class="w-4 h-4 flex-shrink-0" style="color: #fde047;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                Solicita nuevas consultas con disponibilidad real
              </li>
              <li class="flex items-center gap-3 text-sm" style="color: var(--brand-alpha);">
                <svg class="w-4 h-4 flex-shrink-0" style="color: #fde047;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                Vista móvil optimizada
              </li>
            </ul>
            <RouterLink to="/mi-mascota" class="inline-flex items-center gap-2 font-semibold px-8 py-3.5 rounded-xl shadow-md text-base"
              style="background-color: white; color: var(--btn-primary-bg);">
              Entrar a Mi Mascota
            </RouterLink>
          </div>

          <!-- Mockup visual -->
          <div class="section-animate">
            <div class="rounded-2xl overflow-hidden" style="background-color: var(--bg-card); border: 1px solid var(--border-color); box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);">
              <div class="px-5 py-3 flex items-center gap-2" style="background-color: var(--btn-primary-bg);">
                <div class="w-3 h-3 rounded-full bg-white/30" />
                <div class="w-3 h-3 rounded-full bg-white/30" />
                <div class="w-3 h-3 rounded-full bg-white/30" />
                <span class="ml-2 text-xs font-medium" style="color: var(--brand-alpha);">portal.vetdesk.cl/mi-mascota</span>
              </div>
              <div class="p-5">
                <div class="flex items-center gap-3 mb-4">
                  <div class="w-12 h-12 rounded-full flex items-center justify-center text-2xl" style="background-color: var(--brand-alpha);">
                    <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="color: var(--btn-primary-bg);"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 14.5v-9l6 4.5-6 4.5z"/></svg>
                  </div>
                  <div>
                    <p class="font-bold text-base" style="color: var(--text-primary);">Luna</p>
                    <p class="text-xs" style="color: var(--text-muted);">Golden Retriever · Hembra · 3 años</p>
                  </div>
                </div>
                <div class="space-y-3">
                  <div class="rounded-lg p-3" style="background-color: var(--bg-secondary); border: 1px solid var(--border-color);">
                    <p class="text-xs mb-1 font-medium uppercase tracking-wide" style="color: var(--text-muted);">Última consulta</p>
                    <p class="font-semibold text-sm" style="color: var(--text-primary);">Chequeo general</p>
                    <p class="text-xs mt-0.5" style="color: var(--text-muted);">12 Abr 2026 · Santiago</p>
                  </div>
                  <div class="rounded-lg p-3" style="background-color: var(--bg-secondary); border: 1px solid var(--border-color);">
                    <p class="text-xs mb-1 font-medium uppercase tracking-wide" style="color: var(--text-muted);">Diagnóstico</p>
                    <p class="text-sm" style="color: var(--text-primary);">Chequeo cardiológico normal, peso saludable</p>
                  </div>
                  <div class="rounded-lg p-3" style="background-color: var(--bg-secondary); border: 1px solid var(--border-color);">
                    <p class="text-xs mb-1 font-medium uppercase tracking-wide" style="color: var(--text-muted);">Tratamiento</p>
                    <p class="text-sm" style="color: var(--text-primary);">Suplemento vitamínico semanal</p>
                  </div>
                </div>
                <div class="mt-4 pt-4 border-t" style="border-color: var(--border-color);">
                  <RouterLink to="/mi-mascota" class="btn-primary w-full text-sm justify-center text-center py-2.5">
                    Ver historial completo
                  </RouterLink>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Final -->
    <section class="py-24 px-6" style="background-color: var(--bg-secondary);">
      <div class="max-w-3xl mx-auto text-center section-animate">
        <h2 class="text-3xl sm:text-4xl font-bold mb-5 leading-tight tracking-tight" style="color: var(--text-primary);">
          Tu mascota merece<br />
          <span style="color: var(--btn-primary-bg);">la mejor atención</span>
        </h2>
        <p class="text-lg mb-8 leading-relaxed" style="color: var(--text-muted);">
          Completa el formulario y te contactamos en menos de 2 horas hábiles.
        </p>
        <RouterLink to="/solicitar" class="btn-primary text-base px-10 py-3.5 shadow-md">
          Solicitar ahora
        </RouterLink>
      </div>
    </section>

    <!-- Footer -->
    <footer class="py-8 px-6" style="border-top: 1px solid var(--border-color); background-color: var(--bg-card);">
      <div class="max-w-6xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
        <div class="flex items-center gap-2">
          <div class="w-6 h-6 rounded flex items-center justify-center" style="background-color: var(--btn-primary-bg);">
            <svg class="w-4 h-4 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 14.5v-9l6 4.5-6 4.5z"/>
            </svg>
          </div>
          <span class="font-bold" style="color: var(--text-primary);">VetDesk</span>
        </div>
        <p class="text-xs" style="color: var(--text-muted);">
          © 2026 VetDesk · Atención veterinaria a domicilio
        </p>
        <RouterLink to="/login" class="text-xs font-medium transition-colors" style="color: var(--text-muted);">
          Acceso técnico
        </RouterLink>
      </div>
    </footer>

  </div>
</template>
