<script setup>
import { onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { gsap } from 'gsap'

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

onMounted(() => {
  if (prefersReducedMotion) return
  const tl = gsap.timeline()
  tl.from('.hero-animate', { opacity: 0, y: 28, stagger: 0.12, duration: 0.65, ease: 'power2.out', delay: 0.15 })
    .from('.section-animate', { opacity: 0, y: 20, stagger: 0.08, duration: 0.5, ease: 'power2.out' }, '-=0.3')
})

const services = [
  {
    title: 'Vacunación',
    desc: 'Esquemas completos para perros, gatos y más. Certificados oficiales.',
    emoji: '💉',
    svgPath: 'M19 3H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2zm-1 11h-4v4h-4v-4H6v-4h4V6h4v4h4v4z',
    badge: 'Más solicitado',
    badgeType: 'primary',
  },
  {
    title: 'Chequeo general',
    desc: 'Revisión completa del estado de salud de tu mascota a domicilio.',
    emoji: '🩺',
    svgPath: 'M22 12h-4l-3 9L9 3l-3 9H2',
    badge: 'Popular',
    badgeType: 'soft',
  },
  {
    title: 'Desparasitación',
    desc: 'Tratamientos internos y externos adaptados a cada etapa del animal.',
    emoji: '💊',
    svgPath: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z',
  },
  {
    title: 'Corte de pelo',
    desc: 'Baño, corte y limpieza de oídos. Tu mascota lista y feliz.',
    emoji: '✂️',
    svgPath: 'M6 21c1.5-1.5 3-2 5-2s3.5.5 5 2M6 17c1.5-1.5 3-2 5-2s3.5.5 5 2M8 13c0 0 1-2 4-2s4 2 4 2M4 9c0 0 1.5-2 4-2s4 2 4 2M12 2v4M2 12h4M18 12h4',
  },
  {
    title: 'Recetas médicas',
    desc: 'Emitimos recetas válidas para cualquier farmacia veterinaria.',
    emoji: '📋',
    svgPath: 'M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6zm-1 2l5 5h-5V4zM9 13h6M9 17h6M9 9h2',
  },
  {
    title: 'Atención a domicilio',
    desc: 'El veterinario llega a tu casa. Sin estrés para tu mascota.',
    emoji: '🏠',
    svgPath: 'M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z',
  },
]

const steps = [
  {
    num: '01',
    title: 'Llena el formulario',
    desc: 'Dinos qué necesita tu mascota y dónde estás. Tarda menos de 2 minutos.',
    icon: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
  },
  {
    num: '02',
    title: 'Te contactamos',
    desc: 'Confirmamos tu solicitud y coordinamos la mejor hora para visitarlos.',
    icon: 'M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z',
  },
  {
    num: '03',
    title: 'Visitamos a tu mascota',
    desc: 'Llegamos a tu domicilio con todo lo necesario para la atención.',
    icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6',
  },
]

const benefits = [
  { title: 'Respuesta rápida', desc: 'Contactamos en menos de 2 horas hábiles', icon: '⚡' },
  { title: 'En tu hogar', desc: 'Tu mascota se atiende cómoda en su entorno', icon: '🏡' },
  { title: 'Técnicos capacitados', desc: 'Experiencia en atención domiciliaria veterinaria', icon: '🎓' },
  { title: 'Seguimiento continuo', desc: 'Historial clínico digital de cada visita', icon: '📊' },
  { title: 'Precios justos', desc: 'Sin costos ocultos, transparencia total', icon: '💚' },
  { title: 'Insumos certificados', desc: 'Solo medicamentos y productos de calidad', icon: '✅' },
]
</script>

<template>
  <div class="min-h-screen pt-16" style="background-color: var(--bg-primary);">

    <!-- ── Hero ──────────────────────────────────────────── -->
    <section class="relative overflow-hidden pt-20 pb-24 px-6" style="background-color: var(--bg-secondary);">
      <!-- Subtle background accent -->
      <div class="absolute inset-0 pointer-events-none" aria-hidden="true"
        style="background: radial-gradient(ellipse 80% 60% at 50% -10%, rgba(22,163,74,0.10) 0%, transparent 70%);" />

      <div class="relative max-w-4xl mx-auto text-center">
        <!-- Pill badge -->
        <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-sm font-medium mb-7 hero-animate"
          style="background-color: var(--brand-alpha); border: 1px solid var(--border-color); color: var(--btn-primary-bg);">
          <span class="w-2 h-2 rounded-full animate-pulse flex-shrink-0" style="background-color: var(--btn-primary-bg);" aria-hidden="true" />
          Atención a domicilio en toda la región
        </div>

        <!-- Headline -->
        <h1 class="text-4xl sm:text-5xl lg:text-6xl font-bold leading-[1.1] tracking-tight mb-6 hero-animate"
          style="color: var(--text-primary);">
          El médico de tu mascota<br />
          <span style="color: var(--btn-primary-bg);">llega hasta tu puerta</span>
        </h1>

        <!-- Subheadline -->
        <p class="text-lg sm:text-xl max-w-2xl mx-auto mb-10 leading-relaxed hero-animate"
          style="color: var(--text-secondary);">
          Vacunas, chequeos, desparasitación y más — sin estrés para ella, sin complicaciones para ti. Agendamos en minutos.
        </p>

        <!-- CTA buttons -->
        <div class="flex flex-col sm:flex-row gap-4 justify-center hero-animate">
          <RouterLink to="/solicitar" class="btn-primary text-base px-9 py-3.5">
            Solicitar atención ahora
          </RouterLink>
          <RouterLink to="/mi-mascota" class="btn-secondary text-base px-9 py-3.5">
            Portal Mi Mascota
          </RouterLink>
        </div>

        <!-- Social proof bar -->
        <div class="mt-12 inline-flex flex-wrap items-center justify-center gap-x-6 gap-y-3 text-sm hero-animate"
          style="color: var(--text-secondary);">
          <div class="flex items-center gap-2">
            <span style="color: #f59e0b; letter-spacing: -1px;">★★★★★</span>
            <span class="font-semibold" style="color: var(--text-primary);">4.9</span>
            <span style="color: var(--text-muted);">(120 reseñas)</span>
          </div>
          <span class="hidden sm:block w-px h-4" style="background-color: var(--border-color);" aria-hidden="true" />
          <span class="flex items-center gap-1.5">
            <span style="color: var(--btn-primary-bg);">🐾</span>
            <strong style="color: var(--text-primary);">340+</strong> mascotas atendidas
          </span>
          <span class="hidden sm:block w-px h-4" style="background-color: var(--border-color);" aria-hidden="true" />
          <span class="flex items-center gap-1.5">
            <span style="color: var(--btn-primary-bg);">📜</span>
            Certificados oficiales
          </span>
        </div>
      </div>
    </section>

    <!-- ── Servicios ─────────────────────────────────────── -->
    <section id="servicios" class="py-20 px-6" style="background-color: var(--bg-primary);">
      <div class="max-w-6xl mx-auto">
        <div class="text-center mb-14 section-animate">
          <span class="inline-block text-xs font-semibold uppercase tracking-widest mb-3 px-3 py-1 rounded-full"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg);">Servicios</span>
          <h2 class="text-3xl sm:text-4xl font-bold tracking-tight" style="color: var(--text-primary);">Atención completa a domicilio</h2>
          <p class="mt-3 text-lg max-w-xl mx-auto" style="color: var(--text-muted);">Todo lo que tu mascota necesita, sin que tengas que salir de casa</p>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          <div
            v-for="(s, i) in services"
            :key="s.title"
            class="group relative card p-6 transition-all duration-200 hover:-translate-y-1 section-animate"
            style="box-shadow: var(--shadow-card);"
          >
            <!-- Badge -->
            <div v-if="s.badge" class="absolute top-4 right-4">
              <span v-if="s.badgeType === 'primary'"
                class="text-xs font-semibold px-2.5 py-0.5 rounded-full"
                style="background-color: var(--btn-primary-bg); color: #fff;">{{ s.badge }}</span>
              <span v-else
                class="text-xs font-semibold px-2.5 py-0.5 rounded-full"
                style="background-color: var(--brand-alpha); color: var(--btn-primary-bg); border: 1px solid var(--border-color);">{{ s.badge }}</span>
            </div>

            <!-- Icon circle -->
            <div class="w-12 h-12 rounded-xl flex items-center justify-center mb-4 text-2xl transition-colors duration-200"
              style="background-color: var(--bg-secondary);">
              {{ s.emoji }}
            </div>

            <h3 class="text-base font-semibold mb-1.5" style="color: var(--text-primary);">{{ s.title }}</h3>
            <p class="text-sm leading-relaxed" style="color: var(--text-secondary);">{{ s.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- ── Cómo funciona ─────────────────────────────────── -->
    <section id="como-funciona" class="py-20 px-6" style="background-color: var(--bg-secondary);">
      <div class="max-w-5xl mx-auto">
        <div class="text-center mb-16 section-animate">
          <span class="inline-block text-xs font-semibold uppercase tracking-widest mb-3 px-3 py-1 rounded-full"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg);">¿Cómo funciona?</span>
          <h2 class="text-3xl sm:text-4xl font-bold tracking-tight" style="color: var(--text-primary);">Tres pasos simples</h2>
          <p class="mt-3" style="color: var(--text-muted);">De la solicitud a la visita, sin complicaciones</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div v-for="(step, i) in steps" :key="step.num" class="relative text-center section-animate">
            <!-- Connector line -->
            <div v-if="i < 2"
              class="hidden md:block absolute top-8 left-[calc(50%+2.5rem)] right-[-50%]"
              style="height: 2px; background: linear-gradient(to right, var(--border-color), transparent);"
              aria-hidden="true" />

            <!-- Number bubble -->
            <div class="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-5"
              style="background-color: var(--btn-primary-bg); box-shadow: 0 8px 20px var(--btn-primary-shadow);">
              <span class="text-xl font-bold text-white">{{ step.num }}</span>
            </div>

            <!-- Icon -->
            <div class="w-10 h-10 rounded-xl flex items-center justify-center mx-auto mb-4 -mt-2"
              style="background-color: var(--brand-alpha);">
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" :style="{ color: 'var(--btn-primary-bg)' }">
                <path :d="step.icon"/>
              </svg>
            </div>

            <h3 class="text-base font-semibold mb-2" style="color: var(--text-primary);">{{ step.title }}</h3>
            <p class="text-sm leading-relaxed" style="color: var(--text-secondary);">{{ step.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- ── Por qué elegirnos ────────────────────────────── -->
    <section class="py-20 px-6" style="background-color: var(--bg-primary);">
      <div class="max-w-6xl mx-auto">
        <div class="text-center mb-14 section-animate">
          <span class="inline-block text-xs font-semibold uppercase tracking-widest mb-3 px-3 py-1 rounded-full"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg);">Beneficios</span>
          <h2 class="text-3xl sm:text-4xl font-bold tracking-tight" style="color: var(--text-primary);">¿Por qué elegirnos?</h2>
          <p class="mt-3" style="color: var(--text-muted);">La mejor experiencia para ti y tu mascota</p>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="b in benefits"
            :key="b.title"
            class="flex items-start gap-4 p-5 rounded-xl section-animate transition-colors duration-200"
            style="background-color: var(--bg-secondary); border: 1px solid var(--border-color);"
          >
            <div class="w-10 h-10 rounded-xl flex items-center justify-center text-xl flex-shrink-0"
              style="background-color: var(--brand-alpha);">
              {{ b.icon }}
            </div>
            <div>
              <h3 class="font-semibold text-sm mb-1" style="color: var(--text-primary);">{{ b.title }}</h3>
              <p class="text-sm leading-relaxed" style="color: var(--text-secondary);">{{ b.desc }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ── Portal Mi Mascota CTA ────────────────────────── -->
    <section id="mi-mascota" class="py-20 px-6" style="background-color: var(--btn-primary-bg);">
      <div class="max-w-5xl mx-auto">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          <!-- Left: text -->
          <div class="section-animate">
            <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-sm font-semibold mb-5"
              style="background-color: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.25); color: rgba(255,255,255,0.95);">
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
              Nuevo portal para clientes
            </div>

            <h2 class="text-3xl sm:text-4xl font-bold mb-4 leading-tight tracking-tight" style="color: #fff;">
              Consulta el historial<br />de tu mascota
              <span style="color: #fde047;"> en línea</span>
            </h2>

            <p class="mb-7 leading-relaxed text-base" style="color: rgba(255,255,255,0.85);">
              ¿Ya tienes mascota registrada? Accede al portal <strong style="color: #fff; font-weight: 700;">Mi Mascota</strong> para ver el expediente clínico completo: diagnósticos, tratamientos, vacunas y el historial de visitas.
            </p>

            <ul class="space-y-3 mb-9">
              <li v-for="item in ['Historial clínico completo y actualizado', 'Acceso por RUT o teléfono (sin contraseña)', 'Solicita nuevas consultas con disponibilidad real', 'Vista móvil optimizada']"
                :key="item"
                class="flex items-center gap-3 text-sm"
                style="color: rgba(255,255,255,0.88);">
                <svg class="w-4 h-4 flex-shrink-0" style="color: #fde047;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                {{ item }}
              </li>
            </ul>

            <RouterLink to="/mi-mascota"
              class="inline-flex items-center gap-2.5 font-semibold px-8 py-3.5 rounded-xl text-base transition-transform hover:-translate-y-0.5"
              style="background-color: #fff; color: var(--btn-primary-bg); box-shadow: 0 8px 24px rgba(0,0,0,0.15);">
              Entrar a Mi Mascota
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
            </RouterLink>
          </div>

          <!-- Right: mockup card -->
          <div class="section-animate">
            <div class="rounded-2xl overflow-hidden"
              style="background-color: var(--bg-card); border: 1px solid rgba(255,255,255,0.2); box-shadow: 0 30px 60px -12px rgba(0,0,0,0.3);">
              <!-- Browser bar -->
              <div class="px-5 py-3 flex items-center gap-2" style="background-color: rgba(0,0,0,0.15);">
                <div class="flex gap-1.5" aria-hidden="true">
                  <div class="w-3 h-3 rounded-full bg-white/20" />
                  <div class="w-3 h-3 rounded-full bg-white/20" />
                  <div class="w-3 h-3 rounded-full bg-white/20" />
                </div>
                <span class="ml-2 text-xs font-medium" style="color: rgba(255,255,255,0.7);">vetdesk.cl/mi-mascota</span>
              </div>

              <!-- Content -->
              <div class="p-5">
                <!-- Pet header -->
                <div class="flex items-center gap-3 mb-5 pb-4" style="border-bottom: 1px solid var(--card-border);">
                  <div class="w-12 h-12 rounded-xl flex items-center justify-center text-2xl"
                    style="background-color: var(--bg-secondary);">🐕</div>
                  <div>
                    <p class="font-bold text-base" style="color: var(--text-primary);">Luna</p>
                    <p class="text-xs" style="color: var(--text-muted);">Golden Retriever · Hembra · 3 años</p>
                  </div>
                  <span class="ml-auto text-xs px-2 py-0.5 rounded-full font-medium"
                    style="background-color: var(--bg-secondary); color: var(--btn-primary-bg); border: 1px solid var(--border-color);">Activa</span>
                </div>

                <!-- Records -->
                <div class="space-y-2.5">
                  <div class="rounded-xl p-3.5" style="background-color: var(--bg-secondary); border: 1px solid var(--border-color);">
                    <div class="flex items-center justify-between mb-1.5">
                      <p class="text-xs font-semibold uppercase tracking-wide" style="color: var(--btn-primary-bg);">Última consulta</p>
                      <span class="text-xs" style="color: var(--text-muted);">12 Abr 2026</span>
                    </div>
                    <p class="font-semibold text-sm" style="color: var(--text-primary);">Chequeo general</p>
                    <p class="text-xs mt-0.5" style="color: var(--text-muted);">Peso: 28.5 kg · Temp: 38.4°C</p>
                  </div>
                  <div class="rounded-xl p-3.5" style="background-color: var(--bg-secondary); border: 1px solid var(--border-color);">
                    <p class="text-xs font-semibold uppercase tracking-wide mb-1" style="color: var(--text-muted);">Diagnóstico</p>
                    <p class="text-sm" style="color: var(--text-primary);">Chequeo cardiológico normal, peso saludable</p>
                  </div>
                  <div class="rounded-xl p-3.5" style="background-color: var(--bg-secondary); border: 1px solid var(--border-color);">
                    <p class="text-xs font-semibold uppercase tracking-wide mb-1" style="color: var(--text-muted);">Próxima visita</p>
                    <p class="text-sm" style="color: var(--btn-primary-bg);">Refuerzo vacunal en 3 meses</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ── CTA Final ────────────────────────────────────── -->
    <section class="py-24 px-6" style="background-color: var(--bg-secondary);">
      <div class="max-w-3xl mx-auto text-center section-animate">
        <div class="w-16 h-16 rounded-2xl flex items-center justify-center text-3xl mx-auto mb-6"
          style="background-color: var(--brand-alpha); border: 1px solid var(--border-color);">🐾</div>
        <h2 class="text-3xl sm:text-4xl font-bold mb-5 leading-tight tracking-tight" style="color: var(--text-primary);">
          Tu mascota merece<br />
          <span style="color: var(--btn-primary-bg);">la mejor atención</span>
        </h2>
        <p class="text-lg mb-9 leading-relaxed" style="color: var(--text-muted);">
          Completa el formulario y te contactamos en menos de 2 horas hábiles.
        </p>
        <RouterLink to="/solicitar" class="btn-primary text-base px-11 py-3.5">
          Solicitar atención ahora
        </RouterLink>
        <p class="mt-4 text-sm" style="color: var(--text-muted);">Sin pago adelantado · Respuesta garantizada</p>
      </div>
    </section>

    <!-- ── Footer ───────────────────────────────────────── -->
    <footer class="py-8 px-6" style="border-top: 1px solid var(--border-color); background-color: var(--bg-card);">
      <div class="max-w-6xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
        <div class="flex items-center gap-2.5">
          <div class="w-7 h-7 rounded-lg flex items-center justify-center" style="background-color: var(--btn-primary-bg);">
            <span class="text-white text-xs font-bold">V</span>
          </div>
          <span class="font-bold text-base" style="color: var(--text-primary);">VetDesk</span>
        </div>
        <p class="text-xs" style="color: var(--text-muted);">© 2026 VetDesk · Veterinaria móvil a domicilio</p>
        <RouterLink to="/login" class="text-xs font-medium transition-opacity hover:opacity-70" style="color: var(--text-muted);">
          Acceso técnico →
        </RouterLink>
      </div>
    </footer>

  </div>
</template>
