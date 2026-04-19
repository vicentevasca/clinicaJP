<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { gsap } from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
let scrollTriggers = []

onMounted(() => {
  if (prefersReducedMotion) return

  // Hero plays immediately — these are above the fold
  gsap.from('.hero-animate', {
    opacity: 0, y: 28, stagger: 0.12, duration: 0.65, ease: 'power2.out', delay: 0.15
  })

  // All other animated elements use ScrollTrigger so they only animate
  // when they enter the viewport — prevents invisible content while scrolling
  document.querySelectorAll('.section-animate, .testimonial-animate, .faq-animate').forEach(el => {
    const tween = gsap.from(el, {
      opacity: 0,
      y: 20,
      duration: 0.5,
      ease: 'power2.out',
      scrollTrigger: {
        trigger: el,
        start: 'top 90%',
        once: true,
      },
    })
    if (tween.scrollTrigger) scrollTriggers.push(tween.scrollTrigger)
  })
})

onBeforeUnmount(() => {
  scrollTriggers.forEach(st => st?.kill())
  ScrollTrigger.getAll().forEach(st => st.kill())
})

// FAQ open state
const openFaq = ref(null)
function toggleFaq(index) {
  openFaq.value = openFaq.value === index ? null : index
}

const services = [
  {
    title: 'Vacunación',
    desc: 'Esquemas completos para perros, gatos y más. Certificados oficiales emitidos al momento.',
    emoji: '💉',
    svgPath: 'M19 3H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2zm-1 11h-4v4h-4v-4H6v-4h4V6h4v4h4v4z',
    badge: 'Más solicitado',
    badgeType: 'primary',
  },
  {
    title: 'Chequeo general',
    desc: 'Revisión completa de salud — auscultación, peso, temperatura — sin salir de tu casa.',
    emoji: '🩺',
    svgPath: 'M22 12h-4l-3 9L9 3l-3 9H2',
    badge: 'Popular',
    badgeType: 'soft',
  },
  {
    title: 'Desparasitación',
    desc: 'Tratamientos internos y externos adaptados a la especie, peso y etapa del animal.',
    emoji: '💊',
    svgPath: 'M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z',
  },
  {
    title: 'Corte de pelo',
    desc: 'Baño, corte y limpieza de oídos. Tu mascota lista, tranquila y sin el estrés del traslado.',
    emoji: '✂️',
    svgPath: 'M6 21c1.5-1.5 3-2 5-2s3.5.5 5 2M6 17c1.5-1.5 3-2 5-2s3.5.5 5 2M8 13c0 0 1-2 4-2s4 2 4 2M4 9c0 0 1.5-2 4-2s4 2 4 2M12 2v4M2 12h4M18 12h4',
  },
  {
    title: 'Recetas médicas',
    desc: 'Emitimos recetas con validez oficial para cualquier farmacia veterinaria del país.',
    emoji: '📋',
    svgPath: 'M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6zm-1 2l5 5h-5V4zM9 13h6M9 17h6M9 9h2',
  },
  {
    title: 'Atención a domicilio',
    desc: 'El técnico veterinario va donde tú estás, equipado para atender con estándares clínicos.',
    emoji: '🏠',
    svgPath: 'M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z',
  },
]

const steps = [
  {
    num: '01',
    title: 'Llena el formulario',
    desc: 'Cuéntanos qué necesita tu mascota y dónde estás. Tarda menos de 2 minutos.',
    icon: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
  },
  {
    num: '02',
    title: 'Te contactamos',
    desc: 'Confirmamos tu solicitud por WhatsApp y coordinamos el horario que mejor te acomode.',
    icon: 'M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z',
  },
  {
    num: '03',
    title: 'Visitamos a tu mascota',
    desc: 'Llegamos a tu domicilio con todo el equipamiento. Tu mascota se queda tranquila en su casa.',
    icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6',
  },
]

const benefits = [
  { title: 'Respuesta en menos de 2 horas', desc: 'Confirmamos tu solicitud el mismo día, en horario hábil', icon: '⚡' },
  { title: 'Cero estrés para tu mascota', desc: 'Se atiende en su propio entorno, sin viajes ni salas de espera', icon: '🏡' },
  { title: 'Técnico veterinario certificado', desc: 'Título oficial y experiencia comprobada en atención domiciliaria', icon: '🎓' },
  { title: 'Historial clínico digital', desc: 'Cada visita queda registrada y accesible desde el portal', icon: '📊' },
  { title: 'Sin costos ocultos', desc: 'Te informamos el precio antes de confirmar — sin sorpresas', icon: '💚' },
  { title: 'Insumos y vacunas certificados', desc: 'Solo medicamentos y productos de calidad con cadena de frío', icon: '✅' },
]

const testimonials = [
  {
    name: 'María José T.',
    pet: 'Golden Retriever',
    stars: 5,
    text: 'Llegaron en menos de 2 horas y Luna ni se dio cuenta de que la vacunaron. En 30 minutos ya había terminado todo. ¡Increíble la diferencia con llevarla a la clínica!',
    avatar: '🐕',
  },
  {
    name: 'Carlos R.',
    pet: 'Gato persa',
    stars: 5,
    text: 'Mi gato es súper estresado con los viajes — llegaba a la clínica temblando. Con la visita a domicilio fue completamente diferente. Muy profesionales y tranquilos con él.',
    avatar: '🐈',
  },
  {
    name: 'Valentina M.',
    pet: '2 perros Border Collie',
    stars: 5,
    text: 'Ya hemos tenido 3 visitas y siempre llegaron puntuales, con todo el equipamiento. Vacunaron a los dos en 45 minutos y sin dramas. Los recomiendo totalmente.',
    avatar: '🐶',
  },
]

const faqs = [
  {
    q: '¿El técnico veterinario está certificado?',
    a: 'Sí. Todos nuestros técnicos tienen título oficial como Técnico en Medicina Veterinaria y experiencia específica en atención domiciliaria. Puedes pedirles su identificación antes de la visita.',
  },
  {
    q: '¿Cuánto cuesta una visita a domicilio?',
    a: 'El costo varía según el servicio solicitado y la zona. Te informamos el precio exacto sin compromiso al confirmar tu solicitud — sin costos ocultos ni cobros sorpresa.',
  },
  {
    q: '¿Qué comunas de Santiago cubren?',
    a: 'Atendemos Santiago y comunas aledañas. Completa el formulario con tu dirección y te confirmamos cobertura en tu zona inmediatamente.',
  },
  {
    q: '¿Pueden atender mascotas grandes o animales de granja?',
    a: 'Sí. Atendemos perros, gatos, aves, caballos y bovinos según el caso y el servicio requerido. Indícalo en el formulario para que el técnico llegue preparado.',
  },
  {
    q: '¿Es seguro que vengan a mi casa?',
    a: 'Absolutamente. Nuestros técnicos están identificados con credencial, trabajan con protocolo clínico definido y puedes verificar su identidad antes de abrir la puerta. Operamos con total transparencia.',
  },
]
</script>

<template>
  <div class="min-h-screen pt-16" style="background-color: var(--bg-primary);">

    <!-- ── Urgency Banner ──────────────────────────────── -->
    <div class="w-full py-2.5 px-4 text-center text-sm font-medium"
      style="background-color: var(--btn-primary-bg); color: #ffffff;">
      <span>📍 Disponibilidad limitada para esta semana —&nbsp;</span>
      <RouterLink to="/solicitar"
        class="font-bold underline underline-offset-2 hover:opacity-80 transition-opacity">
        Reservar ahora →
      </RouterLink>
    </div>

    <!-- ── Hero ──────────────────────────────────────────── -->
    <section class="relative overflow-hidden pt-20 pb-0 px-6" style="background-color: var(--bg-secondary);">
      <!-- Radial glow accent -->
      <div class="absolute inset-0 pointer-events-none" aria-hidden="true"
        style="background: radial-gradient(ellipse 80% 55% at 50% -5%, rgba(22,163,74,0.13) 0%, transparent 70%);" />

      <div class="relative max-w-4xl mx-auto text-center">
        <!-- Pill badge -->
        <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-sm font-medium mb-7 hero-animate"
          style="background-color: var(--brand-alpha); border: 1px solid var(--border-color); color: var(--btn-primary-bg);">
          <span class="w-2 h-2 rounded-full animate-pulse flex-shrink-0" style="background-color: var(--btn-primary-bg);" aria-hidden="true" />
          Atención disponible · Santiago y comunas aledañas
        </div>

        <!-- Headline -->
        <h1 class="text-5xl sm:text-6xl font-bold leading-[1.08] tracking-tight mb-5 hero-animate"
          style="color: var(--text-primary);">
          Tu mascota, atendida<br />en casa.
          <span style="color: var(--btn-primary-bg);"><br />Sin estrés. Sin traslados.</span>
        </h1>

        <!-- Subheadline -->
        <p class="text-xl sm:text-2xl max-w-2xl mx-auto mb-4 leading-relaxed hero-animate"
          style="color: var(--text-secondary);">
          Sabemos lo difícil que es llevar a tu mascota a la clínica. Por eso el técnico veterinario va a donde tú estás — con todo lo necesario.
        </p>

        <!-- Credential signal -->
        <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold mb-8 hero-animate"
          style="background-color: var(--brand-alpha); border: 1px solid var(--border-color); color: var(--btn-primary-bg);">
          <svg class="w-3.5 h-3.5 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
          </svg>
          Técnico veterinario certificado · Insumos oficiales
        </div>

        <!-- CTA buttons -->
        <div class="flex flex-col sm:flex-row gap-4 justify-center hero-animate">
          <div class="flex flex-col items-center gap-1.5">
            <RouterLink to="/solicitar" class="btn-primary text-base px-10 py-4 rounded-xl font-semibold">
              Solicitar visita gratis
            </RouterLink>
            <span class="text-xs" style="color: var(--text-muted);">Sin compromiso · Respuesta en 2 horas</span>
          </div>
          <a href="#servicios" class="btn-secondary text-base px-10 py-4 rounded-xl font-semibold self-start sm:self-center">
            Ver servicios
          </a>
        </div>

        <!-- Trust bar -->
        <div class="mt-10 mb-0 inline-flex flex-wrap items-center justify-center gap-x-6 gap-y-3 text-sm hero-animate"
          style="color: var(--text-secondary);">
          <div class="flex items-center gap-2">
            <span style="color: #f59e0b; letter-spacing: -1px; font-size: 1rem;">★★★★★</span>
            <span class="font-bold" style="color: var(--text-primary);">4.9</span>
            <span style="color: var(--text-muted);">(120 reseñas)</span>
          </div>
          <span class="hidden sm:block w-px h-4" style="background-color: var(--border-color);" aria-hidden="true" />
          <span class="flex items-center gap-1.5">
            <span style="color: var(--btn-primary-bg);">🐾</span>
            <strong style="color: var(--text-primary);">340+</strong>
            <span style="color: var(--text-muted);">mascotas atendidas</span>
          </span>
          <span class="hidden sm:block w-px h-4" style="background-color: var(--border-color);" aria-hidden="true" />
          <span class="flex items-center gap-1.5" style="color: var(--text-muted);">
            <span style="color: var(--btn-primary-bg);">📜</span>
            Técnicos con título oficial
          </span>
        </div>

        <!-- Wave fade into next section -->
        <div class="relative mt-12 h-16 pointer-events-none" aria-hidden="true">
          <svg viewBox="0 0 1440 64" preserveAspectRatio="none" class="absolute bottom-0 left-0 w-full h-full"
            style="fill: var(--bg-secondary);">
            <path d="M0,32 C360,64 1080,0 1440,32 L1440,64 L0,64 Z" />
          </svg>
        </div>
      </div>
    </section>

    <!-- ── Servicios ─────────────────────────────────────── -->
    <section id="servicios" class="py-20 px-6" style="background-color: var(--bg-secondary);">
      <div class="max-w-6xl mx-auto">
        <div class="text-center mb-14 section-animate">
          <span class="inline-block text-xs font-semibold uppercase tracking-widest mb-3 px-3 py-1 rounded-full"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg);">Servicios</span>
          <h2 class="text-3xl sm:text-4xl font-bold tracking-tight" style="color: var(--text-primary);">
            Todo lo que tu mascota necesita
          </h2>
          <p class="mt-3 text-lg max-w-xl mx-auto" style="color: var(--text-muted);">
            Atención veterinaria completa a domicilio — sin que tengas que salir de casa
          </p>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          <div
            v-for="s in services"
            :key="s.title"
            class="group relative card p-6 transition-all duration-200 hover:-translate-y-1 section-animate"
            style="background-color: var(--bg-card); box-shadow: var(--shadow-card);"
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
              style="background-color: var(--brand-alpha);">
              {{ s.emoji }}
            </div>

            <h3 class="text-base font-semibold mb-1.5" style="color: var(--text-primary);">{{ s.title }}</h3>
            <p class="text-sm leading-relaxed" style="color: var(--text-secondary);">{{ s.desc }}</p>

            <!-- Hover border accent -->
            <div class="absolute inset-0 rounded-[0.875rem] opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none"
              style="box-shadow: 0 0 0 2px var(--card-hover-border);" aria-hidden="true" />
          </div>
        </div>

        <!-- Inline CTA under services -->
        <div class="text-center mt-10 section-animate">
          <RouterLink to="/solicitar" class="btn-primary text-base px-10 py-4 rounded-xl font-semibold inline-block">
            Solicitar visita gratis
          </RouterLink>
          <p class="mt-2 text-sm" style="color: var(--text-muted);">Sin compromiso · Respuesta en 2 horas</p>
        </div>
      </div>
    </section>

    <!-- ── Cómo funciona ─────────────────────────────────── -->
    <section id="como-funciona" class="py-20 px-6" style="background-color: var(--bg-primary);">
      <div class="max-w-5xl mx-auto">
        <div class="text-center mb-16 section-animate">
          <span class="inline-block text-xs font-semibold uppercase tracking-widest mb-3 px-3 py-1 rounded-full"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg);">¿Cómo funciona?</span>
          <h2 class="text-3xl sm:text-4xl font-bold tracking-tight" style="color: var(--text-primary);">3 pasos simples</h2>
          <p class="mt-3 text-base" style="color: var(--text-muted);">De la solicitud a la visita, sin complicaciones ni filas</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-8 relative">
          <!-- Dashed connector line (desktop only) -->
          <div class="hidden md:block absolute top-9 left-[calc(16.67%+2rem)] right-[calc(16.67%+2rem)]"
            aria-hidden="true"
            style="height: 2px; border-top: 2px dashed var(--border-color); top: 2.25rem;" />

          <div v-for="(step, i) in steps" :key="step.num" class="relative text-center section-animate z-10">
            <!-- Number circle -->
            <div class="w-[4.5rem] h-[4.5rem] rounded-2xl flex flex-col items-center justify-center mx-auto mb-5"
              style="background-color: var(--btn-primary-bg); box-shadow: 0 8px 24px var(--btn-primary-shadow);">
              <span class="text-lg font-bold text-white leading-none">{{ step.num }}</span>
            </div>

            <h3 class="text-base font-semibold mb-2" style="color: var(--text-primary);">{{ step.title }}</h3>
            <p class="text-sm leading-relaxed" style="color: var(--text-secondary);">{{ step.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- ── Por qué elegirnos ────────────────────────────── -->
    <section class="py-20 px-6" style="background-color: var(--bg-secondary);">
      <div class="max-w-6xl mx-auto">
        <div class="text-center mb-14 section-animate">
          <span class="inline-block text-xs font-semibold uppercase tracking-widest mb-3 px-3 py-1 rounded-full"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg);">Beneficios</span>
          <h2 class="text-3xl sm:text-4xl font-bold tracking-tight" style="color: var(--text-primary);">
            ¿Por qué elegir atención a domicilio?
          </h2>
          <p class="mt-3 text-base max-w-xl mx-auto" style="color: var(--text-muted);">
            No es solo conveniencia — es una experiencia completamente diferente para tu mascota
          </p>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="b in benefits"
            :key="b.title"
            class="flex items-start gap-4 p-5 rounded-xl section-animate transition-all duration-200 hover:-translate-y-0.5"
            style="background-color: var(--bg-card); border: 1px solid var(--card-border); box-shadow: var(--shadow-card);"
          >
            <!-- Green checkmark icon -->
            <div class="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 mt-0.5"
              style="background-color: var(--brand-alpha);">
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"
                :style="{ color: 'var(--btn-primary-bg)' }">
                <polyline points="20 6 9 17 4 12" />
              </svg>
            </div>
            <div>
              <h3 class="font-semibold text-sm mb-1" style="color: var(--text-primary);">{{ b.title }}</h3>
              <p class="text-sm leading-relaxed" style="color: var(--text-secondary);">{{ b.desc }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ── Testimonios ───────────────────────────────────── -->
    <section class="py-20 px-6" style="background-color: var(--bg-primary);">
      <div class="max-w-6xl mx-auto">
        <div class="text-center mb-14 testimonial-animate">
          <span class="inline-block text-xs font-semibold uppercase tracking-widest mb-3 px-3 py-1 rounded-full"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg);">Testimonios</span>
          <h2 class="text-3xl sm:text-4xl font-bold tracking-tight" style="color: var(--text-primary);">
            Lo que dicen nuestros clientes
          </h2>
          <p class="mt-3 text-base" style="color: var(--text-muted);">
            Resultados reales de dueños que eligieron la visita a domicilio
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div
            v-for="t in testimonials"
            :key="t.name"
            class="testimonial-animate flex flex-col p-6 rounded-2xl"
            style="background-color: var(--bg-card); border: 1px solid var(--card-border); box-shadow: var(--shadow-card);"
          >
            <!-- Stars -->
            <div class="flex items-center gap-0.5 mb-4">
              <span v-for="n in t.stars" :key="n" style="color: #f59e0b; font-size: 1rem;" aria-hidden="true">★</span>
            </div>

            <!-- Quote -->
            <p class="text-sm leading-relaxed flex-1 mb-5" style="color: var(--text-secondary);">
              "{{ t.text }}"
            </p>

            <!-- Author -->
            <div class="flex items-center gap-3 pt-4" style="border-top: 1px solid var(--card-border);">
              <div class="w-10 h-10 rounded-xl flex items-center justify-center text-xl flex-shrink-0"
                style="background-color: var(--brand-alpha);">
                {{ t.avatar }}
              </div>
              <div>
                <p class="text-sm font-semibold" style="color: var(--text-primary);">{{ t.name }}</p>
                <p class="text-xs" style="color: var(--text-muted);">{{ t.pet }}</p>
              </div>
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
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12 6 12 12 16 14"/>
              </svg>
              Nuevo portal para clientes
            </div>

            <h2 class="text-3xl sm:text-4xl font-bold mb-4 leading-tight tracking-tight" style="color: #ffffff;">
              Consulta el historial<br />de tu mascota
              <span style="color: #fde047;"> en línea</span>
            </h2>

            <p class="mb-7 leading-relaxed text-base" style="color: rgba(255,255,255,0.85);">
              ¿Ya tienes mascota registrada? Accede al portal <strong style="color: #ffffff; font-weight: 700;">Mi Mascota</strong> para ver el expediente clínico completo: diagnósticos, tratamientos, vacunas y el historial de visitas.
            </p>

            <ul class="space-y-3 mb-9">
              <li
                v-for="item in ['Historial clínico completo y actualizado', 'Acceso por RUT o teléfono (sin contraseña)', 'Solicita nuevas consultas con disponibilidad real', 'Vista móvil optimizada']"
                :key="item"
                class="flex items-center gap-3 text-sm"
                style="color: rgba(255,255,255,0.88);">
                <svg class="w-4 h-4 flex-shrink-0" style="color: #fde047;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                  <polyline points="20 6 9 17 4 12"/>
                </svg>
                {{ item }}
              </li>
            </ul>

            <RouterLink to="/mi-mascota"
              class="inline-flex items-center gap-2.5 font-semibold px-8 py-3.5 rounded-xl text-base transition-transform hover:-translate-y-0.5"
              style="background-color: #ffffff; color: var(--btn-primary-bg); box-shadow: 0 8px 24px rgba(0,0,0,0.15);">
              Entrar a Mi Mascota
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M5 12h14M12 5l7 7-7 7"/>
              </svg>
            </RouterLink>
          </div>

          <!-- Right: mockup card -->
          <div class="section-animate">
            <div class="rounded-2xl overflow-hidden"
              style="background-color: var(--bg-card); border: 1px solid rgba(255,255,255,0.2); box-shadow: 0 30px 60px -12px rgba(0,0,0,0.3);">
              <!-- Browser bar -->
              <div class="px-5 py-3 flex items-center gap-2" style="background-color: rgba(0,0,0,0.15);">
                <div class="flex gap-1.5" aria-hidden="true">
                  <div class="w-3 h-3 rounded-full" style="background-color: rgba(255,255,255,0.2);" />
                  <div class="w-3 h-3 rounded-full" style="background-color: rgba(255,255,255,0.2);" />
                  <div class="w-3 h-3 rounded-full" style="background-color: rgba(255,255,255,0.2);" />
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

    <!-- ── FAQ ───────────────────────────────────────────── -->
    <section class="py-20 px-6" style="background-color: var(--bg-secondary);">
      <div class="max-w-3xl mx-auto">
        <div class="text-center mb-14 faq-animate">
          <span class="inline-block text-xs font-semibold uppercase tracking-widest mb-3 px-3 py-1 rounded-full"
            style="background-color: var(--brand-alpha); color: var(--btn-primary-bg);">Preguntas frecuentes</span>
          <h2 class="text-3xl sm:text-4xl font-bold tracking-tight" style="color: var(--text-primary);">
            Resolvemos tus dudas
          </h2>
          <p class="mt-3 text-base" style="color: var(--text-muted);">
            Todo lo que necesitas saber antes de agendar tu primera visita
          </p>
        </div>

        <div class="space-y-3">
          <div
            v-for="(faq, index) in faqs"
            :key="index"
            class="faq-animate rounded-2xl overflow-hidden transition-all duration-200"
            style="background-color: var(--bg-card); border: 1px solid var(--card-border); box-shadow: var(--shadow-card);"
          >
            <!-- Question row -->
            <button
              class="w-full flex items-center justify-between gap-4 px-6 py-4 text-left transition-colors duration-150 focus:outline-none"
              :style="{ backgroundColor: openFaq === index ? 'var(--brand-alpha)' : 'transparent' }"
              @click="toggleFaq(index)"
              :aria-expanded="openFaq === index"
            >
              <span class="font-semibold text-sm sm:text-base" style="color: var(--text-primary);">{{ faq.q }}</span>
              <span
                class="flex-shrink-0 w-7 h-7 rounded-full flex items-center justify-center transition-transform duration-200"
                :style="{ backgroundColor: 'var(--brand-alpha)', transform: openFaq === index ? 'rotate(45deg)' : 'rotate(0deg)' }"
                aria-hidden="true"
              >
                <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"
                  :style="{ color: 'var(--btn-primary-bg)' }">
                  <line x1="12" y1="5" x2="12" y2="19" />
                  <line x1="5" y1="12" x2="19" y2="12" />
                </svg>
              </span>
            </button>

            <!-- Answer panel -->
            <div
              v-show="openFaq === index"
              class="px-6 pb-5"
            >
              <p class="text-sm leading-relaxed" style="color: var(--text-secondary);">{{ faq.a }}</p>
            </div>
          </div>
        </div>

        <!-- FAQ bottom CTA -->
        <div class="text-center mt-10 faq-animate">
          <p class="text-sm mb-4" style="color: var(--text-muted);">¿Tienes otra pregunta? Contáctanos directamente.</p>
          <RouterLink to="/solicitar" class="btn-primary text-sm px-8 py-3.5 rounded-xl font-semibold inline-block">
            Hablar con nosotros
          </RouterLink>
        </div>
      </div>
    </section>

    <!-- ── CTA Final ────────────────────────────────────── -->
    <section class="py-24 px-6" style="background-color: var(--bg-primary);">
      <div class="max-w-3xl mx-auto text-center section-animate">
        <div class="w-16 h-16 rounded-2xl flex items-center justify-center text-3xl mx-auto mb-6"
          style="background-color: var(--brand-alpha); border: 1px solid var(--border-color);">🐾</div>
        <h2 class="text-3xl sm:text-4xl font-bold mb-4 leading-tight tracking-tight" style="color: var(--text-primary);">
          Tu mascota merece no sufrir<br />
          <span style="color: var(--btn-primary-bg);">el estrés de la clínica</span>
        </h2>
        <p class="text-lg mb-3 leading-relaxed" style="color: var(--text-muted);">
          Pide tu visita ahora y nos ponemos en contacto en menos de 2 horas.
        </p>

        <!-- Social proof nudge -->
        <p class="text-sm mb-8 font-medium" style="color: var(--text-secondary);">
          <span style="color: #f59e0b;">★★★★★</span>&nbsp; Más de 340 mascotas atendidas en Santiago
        </p>

        <RouterLink to="/solicitar" class="btn-primary text-base px-12 py-4 rounded-xl font-semibold inline-block">
          Solicitar visita gratis
        </RouterLink>
        <p class="mt-3 text-sm" style="color: var(--text-muted);">Sin compromiso · Sin pago adelantado · Respuesta garantizada</p>
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
        <p class="text-xs" style="color: var(--text-muted);">© 2026 VetDesk · Veterinaria móvil a domicilio · Santiago, Chile</p>
        <RouterLink to="/login" class="text-xs font-medium transition-opacity hover:opacity-70" style="color: var(--text-muted);">
          Acceso técnico →
        </RouterLink>
      </div>
    </footer>

  </div>
</template>
