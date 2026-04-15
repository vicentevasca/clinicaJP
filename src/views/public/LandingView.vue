<script setup>
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { gsap } from 'gsap'

const heroRef = ref(null)

onMounted(() => {
  const tl = gsap.timeline()
  tl.from('.hero-animate', { opacity: 0, y: 30, stagger: 0.15, duration: 0.6, delay: 0.2 })
      .from('.section-animate', { opacity: 0, y: 20, stagger: 0.1, duration: 0.5 }, '-=0.3')
})

const services = [
  {
    icon: '💉',
    title: 'Vacunación',
    desc: 'Esquemas completos para perros, gatos y más. Certificados oficiales.'
  },
  {
    icon: '🩺',
    title: 'Chequeo general',
    desc: 'Revisión completa del estado de salud de tu mascota a domicilio.'
  },
  {
    icon: '💊',
    title: 'Desparasitación',
    desc: 'Tratamientos internos y externos adaptados a cada etapa del animal.'
  },
  {
    icon: '✂️',
    title: 'Corte de pelo',
    desc: 'Baño, corte y limpieza de oídos. Tu mascota lista y feliz.'
  },
  {
    icon: '📋',
    title: 'Recetas médicas',
    desc: 'Emitimos recetas válidas para cualquier farmacia veterinaria.'
  },
  {
    icon: '🏠',
    title: 'Atención a domicilio',
    desc: 'El veterinario llega a tu casa. Sin estrés para tu mascota.'
  },
]

const steps = [
  {
    num: '01',
    title: 'Llena el formulario',
    desc: 'Dinos qué necesita tu mascota y dónde estás. Takes menos de 2 minutos.'
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
  },
]

const benefits = [
  { icon: '⚡', title: 'Respuesta rápida', desc: 'Contactamos en menos de 2 horas hábiles' },
  { icon: '🏡', title: 'En tu hogar', desc: 'Tu mascota se atiende cómoda en su entorno' },
  { icon: '🩺', title: 'Veterinarios capacitados', desc: 'Técnicos con experiencia en atención domiciliaria' },
  { icon: '📱', title: 'Seguimiento continuo', desc: 'Historial clínico digital de cada visita' },
  { icon: '💰', title: 'Precios justos', desc: 'Sin costos ocultos, transparencia total' },
  { icon: '🌿', title: 'Insumos de calidad', desc: 'Solo medicamentos y productos certificados' },
]
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">

    <!-- Navbar -->
    <nav class="fixed top-0 left-0 right-0 z-50 bg-slate-900/80 backdrop-blur-md border-b border-slate-700/50">
      <div class="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
        <div class="flex items-center gap-2">
          <span class="text-2xl">🐾</span>
          <span class="text-lg font-bold text-white">VetDesk</span>
        </div>
        <div class="flex items-center gap-4">
          <a href="#servicios" class="hidden sm:block text-sm text-slate-400 hover:text-white transition-colors">Servicios</a>
          <a href="#como-funciona" class="hidden sm:block text-sm text-slate-400 hover:text-white transition-colors">Cómo funciona</a>
          <RouterLink to="/mi-mascota" class="hidden sm:block text-sm text-brand-400 hover:text-brand-300 transition-colors font-medium">
            Mi Mascota
          </RouterLink>
          <RouterLink to="/solicitar" class="btn-primary text-sm">
            Solicitar visita
          </RouterLink>
        </div>
      </div>
    </nav>

    <!-- Hero -->
    <section class="pt-32 pb-20 px-6">
      <div class="max-w-4xl mx-auto text-center" ref="heroRef">
        <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-brand-500/10 border border-brand-500/20 text-brand-400 text-sm font-medium mb-6 hero-animate">
          <span class="w-1.5 h-1.5 rounded-full bg-brand-500 animate-pulse" />
          Atención a domicilio en toda la región
        </div>
        <h1 class="text-4xl sm:text-5xl lg:text-6xl font-bold text-white leading-tight mb-6 hero-animate">
          Veterinaria a domicilio<br />
          <span class="text-brand-400">sin complicaciones</span>
        </h1>
        <p class="text-lg sm:text-xl text-slate-400 max-w-2xl mx-auto mb-10 hero-animate">
          Llegamos hasta tu hogar para atender a tu mascota. Vacunas, chequeos, desparasitación y más — sin estrés para ella, sin奔波 para ti.
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center hero-animate">
          <RouterLink to="/solicitar" class="btn-primary text-base px-8 py-3">
            Solicitar atención →
          </RouterLink>
          <RouterLink to="/mi-mascota" class="btn-secondary text-base px-8 py-3">
            Mi Mascota
          </RouterLink>
        </div>
        <div class="mt-12 flex items-center justify-center gap-8 text-sm text-slate-500 hero-animate">
          <div class="flex items-center gap-2">
            <span class="text-brand-400">✓</span>
            <span>Sin costo de traslado</span>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-brand-400">✓</span>
            <span>Respuesta en menos de 2h</span>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-brand-400">✓</span>
            <span>Pago en efectivo o transferencia</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Servicios -->
    <section id="servicios" class="py-20 px-6 bg-slate-800/30">
      <div class="max-w-6xl mx-auto">
        <div class="text-center mb-14 section-animate">
          <h2 class="text-3xl font-bold text-white mb-4">Servicios disponibles</h2>
          <p class="text-slate-400 max-w-lg mx-auto">Atención completa para tu mascota, directo desde la comodidad de tu hogar</p>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          <div v-for="s in services" :key="s.title"
            class="card p-6 hover:border-brand-500/30 transition-all hover:-translate-y-1 section-animate">
            <span class="text-3xl mb-3 block">{{ s.icon }}</span>
            <h3 class="text-lg font-semibold text-white mb-2">{{ s.title }}</h3>
            <p class="text-sm text-slate-400 leading-relaxed">{{ s.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Cómo funciona -->
    <section id="como-funciona" class="py-20 px-6">
      <div class="max-w-5xl mx-auto">
        <div class="text-center mb-14 section-animate">
          <h2 class="text-3xl font-bold text-white mb-4">¿Cómo funciona?</h2>
          <p class="text-slate-400">Tres pasos simples para la atención de tu mascota</p>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div v-for="(step, i) in steps" :key="step.num"
            class="text-center section-animate relative">
            <div class="w-16 h-16 rounded-full bg-brand-600/20 border-2 border-brand-500/30 flex items-center justify-center mx-auto mb-4">
              <span class="text-2xl font-bold text-brand-400">{{ step.num }}</span>
            </div>
            <div v-if="i < 2" class="hidden md:block absolute top-8 left-[60%] w-[80%] border-t border-dashed border-slate-700" />
            <h3 class="text-lg font-semibold text-white mb-2">{{ step.title }}</h3>
            <p class="text-sm text-slate-400 leading-relaxed">{{ step.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Por qué elegirnos -->
    <section class="py-20 px-6 bg-slate-800/30">
      <div class="max-w-6xl mx-auto">
        <div class="text-center mb-14 section-animate">
          <h2 class="text-3xl font-bold text-white mb-4">¿Por qué elegirnos?</h2>
          <p class="text-slate-400">La mejor experiencia para ti y tu mascota</p>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          <div v-for="b in benefits" :key="b.title"
            class="flex items-start gap-4 p-4 rounded-xl bg-slate-800/40 border border-slate-700/40 section-animate">
            <span class="text-2xl flex-shrink-0">{{ b.icon }}</span>
            <div>
              <h3 class="font-semibold text-white mb-1">{{ b.title }}</h3>
              <p class="text-xs text-slate-400 leading-relaxed">{{ b.desc }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Mi Mascota -->
    <section id="mi-mascota" class="py-20 px-6 bg-slate-800/30">
      <div class="max-w-5xl mx-auto">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          <div class="section-animate">
            <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-brand-500/10 border border-brand-500/20 text-brand-400 text-sm font-medium mb-4">
              🐾 Nuevo portal para clientes
            </div>
            <h2 class="text-3xl sm:text-4xl font-bold text-white mb-4">
              Consulta el historial<br />
              <span class="text-brand-400">de tu mascota</span> desde la web
            </h2>
            <p class="text-slate-400 mb-6 leading-relaxed">
              ¿Ya tienes mascota registrada con nosotros? Accede al portal <strong class="text-white">Mi Mascota</strong> para ver el expediente clínico completo de tu compañero: diagnósticos, tratamientos, vacunas aplicadas y el historial de visitas a domicilio.
            </p>
            <ul class="space-y-3 mb-8">
              <li class="flex items-center gap-3 text-sm text-slate-300">
                <span class="text-brand-400">✓</span>
                Historial clínico completo y actualizado
              </li>
              <li class="flex items-center gap-3 text-sm text-slate-300">
                <span class="text-brand-400">✓</span>
                Acceso por RUT o teléfono (sin contraseña)
              </li>
              <li class="flex items-center gap-3 text-sm text-slate-300">
                <span class="text-brand-400">✓</span>
                Solicita nuevas consultas con disponibilidad real
              </li>
              <li class="flex items-center gap-3 text-sm text-slate-300">
                <span class="text-brand-400">✓</span>
                Vista móvil optimizada
              </li>
            </ul>
            <RouterLink to="/mi-mascota" class="btn-primary text-base px-8 py-3">
              Entrar a Mi Mascota →
            </RouterLink>
          </div>

          <!-- Mockup visual -->
          <div class="section-animate">
            <div class="card p-6 bg-slate-800/60 border border-slate-700/50">
              <div class="flex items-center gap-3 mb-4">
                <div class="w-10 h-10 rounded-full bg-brand-600/20 flex items-center justify-center text-lg">🐕</div>
                <div>
                  <p class="text-white font-semibold text-sm">Luna</p>
                  <p class="text-slate-500 text-xs">Golden Retriever · Hembra</p>
                </div>
              </div>
              <div class="space-y-3">
                <div class="bg-slate-700/40 rounded-lg p-3 border border-slate-600/30">
                  <p class="text-xs text-slate-500 mb-1">Última consulta</p>
                  <p class="text-sm text-white">Chequeo general</p>
                  <p class="text-xs text-slate-400 mt-0.5">12 Abr 2026 · Santiago</p>
                </div>
                <div class="bg-slate-700/40 rounded-lg p-3 border border-slate-600/30">
                  <p class="text-xs text-slate-500 mb-1">Diagnóstico</p>
                  <p class="text-sm text-white">Chequeo cardiológico normal, peso saludable</p>
                </div>
                <div class="bg-slate-700/40 rounded-lg p-3 border border-slate-600/30">
                  <p class="text-xs text-slate-500 mb-1">Tratamiento</p>
                  <p class="text-sm text-white">Suplemento vitamínico semanal</p>
                </div>
              </div>
              <div class="mt-4 pt-4 border-t border-slate-700">
                <RouterLink to="/mi-mascota" class="btn-primary w-full text-sm justify-center text-center">
                  📋 Ver historial completo
                </RouterLink>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Final -->
    <section class="py-24 px-6">
      <div class="max-w-3xl mx-auto text-center section-animate">
        <h2 class="text-3xl sm:text-4xl font-bold text-white mb-5">
          Tu mascota merece<br />
          <span class="text-brand-400">la mejor atención</span>
        </h2>
        <p class="text-slate-400 text-lg mb-8">
          No esperes más. Llena el formulario y nos pondremos en contacto contigo hoy mismo.
        </p>
        <RouterLink to="/solicitar" class="btn-primary text-base px-10 py-3.5">
          Solicitar ahora 🐾
        </RouterLink>
      </div>
    </section>

    <!-- Footer -->
    <footer class="border-t border-slate-700/50 py-8 px-6">
      <div class="max-w-6xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
        <div class="flex items-center gap-2">
          <span class="text-xl">🐾</span>
          <span class="font-semibold text-white">VetDesk</span>
        </div>
        <p class="text-xs text-slate-600">
          © 2026 VetDesk · Atención veterinaria a domicilio
        </p>
        <RouterLink to="/login" class="text-xs text-slate-500 hover:text-slate-300 transition-colors">
          Acceso técnico →
        </RouterLink>
      </div>
    </footer>

  </div>
</template>
