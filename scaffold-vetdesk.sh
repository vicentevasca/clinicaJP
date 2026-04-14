
info "Instalando dependencias..."
npm install \
  vue-router@4 \
  pinia \
  @supabase/supabase-js \
  gsap \
  @vueuse/core

npm install -D \
  tailwindcss \
  postcss \
  autoprefixer \
  @tailwindcss/forms \
  @tailwindcss/typography

log "Dependencias instaladas"

# =============================================================================
# 3. Tailwind CSS
# =============================================================================
info "Configurando Tailwind CSS..."
npx tailwindcss init -p

cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50:  '#f0fdf4',
          100: '#dcfce7',
          200: '#bbf7d0',
          300: '#86efac',
          400: '#4ade80',
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d',
          800: '#166534',
          900: '#14532d',
          950: '#052e16',
        },
        surface: {
          DEFAULT: '#0f172a',
          card:    '#1e293b',
          border:  '#334155',
          muted:   '#475569',
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
EOF
log "tailwind.config.js generado"

# =============================================================================
# 4. vite.config.js
# =============================================================================
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    port: 5173,
  }
})
EOF
log "vite.config.js generado"

# =============================================================================
# 5. Variables de entorno
# =============================================================================
info "Creando archivos de entorno..."
cat > .env.example << 'EOF'
# Supabase
VITE_SUPABASE_URL=https://xxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...

# Solo en Edge Functions (NO en frontend)
SUPABASE_SERVICE_ROLE_KEY=eyJ...

# Telegram Bot
TELEGRAM_BOT_TOKEN=
TELEGRAM_WEBHOOK_SECRET=
TELEGRAM_ADMIN_CHAT_ID=

# Email - Resend
RESEND_API_KEY=re_...
RESEND_FROM_EMAIL=notificaciones@vetdesk.cl

# App
VITE_APP_NAME=VetDesk
VITE_APP_URL=https://vetdesk.vercel.app
VITE_PANEL_URL=https://vetdesk.vercel.app/app

# WhatsApp (número del técnico sin + ni espacios)
VITE_TECH_WHATSAPP=56912345678

# Zona horaria del sistema
VITE_TIMEZONE=America/Santiago
EOF

cp .env.example .env.local
warn ".env.local creado — agrega tus credenciales reales"
log ".env.example y .env.local generados"

# =============================================================================
# 6. .gitignore
# =============================================================================
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.pnp
.pnp.js

# Build
dist/
dist-ssr/
*.local

# Environment
.env.local
.env.*.local

# Editor
.vscode/*
!.vscode/extensions.json
.idea
.DS_Store
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# Supabase
supabase/.branches
supabase/.temp
EOF
log ".gitignore generado"

# =============================================================================
# 7. Estructura de carpetas src/
# =============================================================================
info "Generando estructura de carpetas..."

# Limpiar src default de Vite
rm -f src/components/HelloWorld.vue
rm -f src/style.css
rm -rf src/assets/vue.svg public/vite.svg

# Crear directorios
mkdir -p src/{router,stores,layouts,composables,services,utils}
mkdir -p src/assets/{styles,icons}
mkdir -p src/components/{ui,leads,agenda,inventory,clinical,dashboard}
mkdir -p src/views/{public,auth,app}

log "Directorios creados"

# =============================================================================
# 8. Estilos base
# =============================================================================
cat > src/assets/styles/main.css << 'EOF'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --color-brand: theme('colors.brand.500');
    --color-surface: theme('colors.surface.DEFAULT');
    --color-card: theme('colors.surface.card');
    --color-border: theme('colors.surface.border');
  }

  html { @apply bg-[#0f172a] text-slate-100 antialiased; }
  body { @apply min-h-screen; }

  * { @apply box-border; }
}

@layer components {
  .btn-primary {
    @apply inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-lg 
           bg-brand-600 hover:bg-brand-500 text-white font-medium text-sm
           transition-colors duration-150 disabled:opacity-50 disabled:cursor-not-allowed;
  }
  .btn-secondary {
    @apply inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-lg
           bg-slate-700 hover:bg-slate-600 text-slate-100 font-medium text-sm
           border border-slate-600 transition-colors duration-150;
  }
  .btn-ghost {
    @apply inline-flex items-center justify-center gap-2 px-3 py-2 rounded-lg
           hover:bg-slate-700/60 text-slate-300 hover:text-slate-100 text-sm
           transition-colors duration-150;
  }
  .card {
    @apply bg-slate-800/60 border border-slate-700/60 rounded-xl backdrop-blur-sm;
  }
  .input-base {
    @apply w-full px-3 py-2.5 rounded-lg bg-slate-800 border border-slate-700 
           text-slate-100 placeholder-slate-500 text-sm
           focus:outline-none focus:ring-2 focus:ring-brand-500/50 focus:border-brand-500
           transition-colors duration-150;
  }
  .label-base {
    @apply block text-sm font-medium text-slate-300 mb-1.5;
  }
  .badge {
    @apply inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium;
  }
}
EOF

cat > src/assets/styles/animations.css << 'EOF'
/* Clases base para animaciones GSAP */
.gsap-fade-in    { opacity: 0; }
.gsap-slide-up   { opacity: 0; transform: translateY(20px); }
.gsap-slide-down { opacity: 0; transform: translateY(-20px); }
.gsap-scale-in   { opacity: 0; transform: scale(0.95); }

/* Transiciones de Vue Router */
.page-enter-active,
.page-leave-active { transition: opacity 0.2s ease, transform 0.2s ease; }
.page-enter-from   { opacity: 0; transform: translateY(8px); }
.page-leave-to     { opacity: 0; transform: translateY(-8px); }

/* Loader spinner */
.spinner {
  width: 20px; height: 20px;
  border: 2px solid rgba(255,255,255,0.2);
  border-top-color: #22c55e;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
EOF
log "Estilos base generados"

# =============================================================================
# 9. Utils
# =============================================================================
cat > src/utils/constants.js << 'EOF'
// Lead status
export const LEAD_STATUS = {
  WAITING:     'waiting',
  IN_PROGRESS: 'in_progress',
  DONE:        'done',
  CANCELLED:   'cancelled',
}

export const LEAD_STATUS_LABELS = {
  waiting:     'En espera',
  in_progress: 'En curso',
  done:        'Cerrado',
  cancelled:   'Cancelado',
}

export const LEAD_STATUS_COLORS = {
  waiting:     'bg-amber-500/20 text-amber-400 border-amber-500/30',
  in_progress: 'bg-blue-500/20 text-blue-400 border-blue-500/30',
  done:        'bg-brand-500/20 text-brand-400 border-brand-500/30',
  cancelled:   'bg-slate-500/20 text-slate-400 border-slate-500/30',
}

// Visit status
export const VISIT_STATUS = {
  SCHEDULED:   'scheduled',
  CONFIRMED:   'confirmed',
  IN_PROGRESS: 'in_progress',
  COMPLETED:   'completed',
  CANCELLED:   'cancelled',
}

// Animal species
export const ANIMAL_SPECIES = [
  { value: 'perro',   label: 'Perro' },
  { value: 'gato',    label: 'Gato' },
  { value: 'ave',     label: 'Ave' },
  { value: 'gallina', label: 'Gallina' },
  { value: 'caballo', label: 'Caballo' },
  { value: 'bovino',  label: 'Bovino' },
  { value: 'otro',    label: 'Otro' },
]

// Service types
export const SERVICE_TYPES = [
  { value: 'vacunacion',         label: 'Vacunación' },
  { value: 'desparasitacion',    label: 'Desparasitación' },
  { value: 'chequeo',            label: 'Chequeo general' },
  { value: 'receta',             label: 'Receta médica' },
  { value: 'corte_pelo',         label: 'Corte de pelo' },
  { value: 'atencion_domicilio', label: 'Atención a domicilio' },
  { value: 'otro',               label: 'Otro' },
]

// Priority
export const PRIORITY_LEVELS = [
  { value: 'low',    label: 'Baja',    color: 'text-slate-400' },
  { value: 'normal', label: 'Normal',  color: 'text-blue-400' },
  { value: 'high',   label: 'Alta',    color: 'text-amber-400' },
  { value: 'urgent', label: 'Urgente', color: 'text-red-400' },
]

// User roles
export const USER_ROLES = {
  ADMIN:     'admin',
  TECNICO:   'tecnico',
  ASISTENTE: 'asistente',
}

// Timezone
export const TZ = import.meta.env.VITE_TIMEZONE || 'America/Santiago'
EOF

cat > src/utils/formatters.js << 'EOF'
import { TZ } from './constants.js'

// Fecha legible: "14 abr 2026"
export function formatDate(dateStr) {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat('es-CL', {
    day: 'numeric', month: 'short', year: 'numeric',
    timeZone: TZ,
  }).format(new Date(dateStr))
}

// Fecha + hora: "14 abr 2026, 14:30"
export function formatDateTime(dateStr) {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat('es-CL', {
    day: 'numeric', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
    timeZone: TZ,
  }).format(new Date(dateStr))
}

// Solo hora: "14:30"
export function formatTime(dateStr) {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat('es-CL', {
    hour: '2-digit', minute: '2-digit',
    timeZone: TZ,
  }).format(new Date(dateStr))
}

// Tiempo relativo: "hace 5 min"
export function formatRelative(dateStr) {
  if (!dateStr) return '—'
  const diff = Date.now() - new Date(dateStr).getTime()
  const mins = Math.floor(diff / 60000)
  if (mins < 1)   return 'ahora'
  if (mins < 60)  return `hace ${mins} min`
  const hrs = Math.floor(mins / 60)
  if (hrs < 24)   return `hace ${hrs}h`
  const days = Math.floor(hrs / 24)
  return `hace ${days}d`
}

// Moneda CLP: "$12.500"
export function formatCLP(amount) {
  if (amount == null) return '—'
  return new Intl.NumberFormat('es-CL', {
    style: 'currency', currency: 'CLP',
    minimumFractionDigits: 0,
  }).format(amount)
}

// Teléfono normalizado: "+56 9 1234 5678"
export function formatPhone(phone) {
  if (!phone) return '—'
  const clean = phone.replace(/\D/g, '')
  if (clean.startsWith('56') && clean.length === 11) {
    return `+56 ${clean[2]} ${clean.slice(3,7)} ${clean.slice(7)}`
  }
  return phone
}

// Truncar texto
export function truncate(str, max = 80) {
  if (!str) return ''
  return str.length > max ? str.slice(0, max) + '…' : str
}
EOF

cat > src/utils/validators.js << 'EOF'
// Teléfono chileno: +569XXXXXXXX o 569XXXXXXXX o 9XXXXXXXX
export function isValidChilePhone(phone) {
  const clean = phone.replace(/\D/g, '')
  return /^(56)?9\d{8}$/.test(clean)
}

// Normalizar a +56XXXXXXXXX
export function normalizePhone(phone) {
  const clean = phone.replace(/\D/g, '')
  if (clean.startsWith('56')) return `+${clean}`
  if (clean.startsWith('9') && clean.length === 9) return `+56${clean}`
  return phone
}

export function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
}

export function isRequired(value) {
  return value !== null && value !== undefined && String(value).trim() !== ''
}

export function minLength(value, min) {
  return String(value || '').trim().length >= min
}
EOF

cat > src/utils/whatsapp.js << 'EOF'
const TECH_PHONE = import.meta.env.VITE_TECH_WHATSAPP || '56912345678'

export const WA_TEMPLATES = {
  initial_contact: (clientName, animalName) =>
    `Hola ${clientName}! te hablo desde la clínica a domicilio JP, leí tu mensaje por nuestra plataforma web y me gustaría saber más sobre el caso de ${animalName}. ¿Tienes un momento para conversar?`,

  visit_confirmation: (clientName, animalName, date, time, address) =>
    `Hola ${clientName}! confirmo tu visita para ${animalName} el ${date} a las ${time} en ${address}. Cualquier consulta, escríbeme aquí. ¡Nos vemos pronto! 🐾`,

  follow_up: (clientName, animalName, pendingNote = '') =>
    `Hola ${clientName}! te escribo para hacer seguimiento al caso de ${animalName}. ¿Cómo ha estado?${pendingNote ? ` ¿Pudiste conseguir ${pendingNote}?` : ''}`,
}

export function buildWALink(phone, text) {
  const clean = phone.replace(/\D/g, '')
  return `https://wa.me/${clean}?text=${encodeURIComponent(text)}`
}

export function buildWALinkFromLead(lead) {
  if (!lead?.client?.phone) return null
  const text = WA_TEMPLATES.initial_contact(
    lead.client.name,
    lead.animal?.name || 'tu mascota'
  )
  return buildWALink(lead.client.phone, text)
}
EOF
log "Utils generados"

# =============================================================================
# 10. Supabase service
# =============================================================================
cat > src/services/supabase.js << 'EOF'
import { createClient } from '@supabase/supabase-js'

const supabaseUrl  = import.meta.env.VITE_SUPABASE_URL
const supabaseKey  = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseKey) {
  console.error('[VetDesk] Faltan variables de entorno de Supabase. Revisa .env.local')
}

export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
  }
})
EOF

cat > src/services/leads.service.js << 'EOF'
import { supabase } from './supabase.js'

const LEAD_SELECT = `
  id, status, service_type, description, priority, source,
  confidence_score, inventory_checked, inventory_ok,
  created_at, updated_at,
  client:clients(id, name, phone, email, region, comuna, address),
  animal:animals(id, name, species, breed, sex, weight_kg),
  assigned:users(id, name)
`

export const leadsService = {
  async getAll(filters = {}) {
    let q = supabase.from('leads').select(LEAD_SELECT).order('created_at', { ascending: false })
    if (filters.status)      q = q.eq('status', filters.status)
    if (filters.assigned_to) q = q.eq('assigned_to', filters.assigned_to)
    const { data, error } = await q
    if (error) throw error
    return data
  },

  async getById(id) {
    const { data, error } = await supabase
      .from('leads').select(LEAD_SELECT).eq('id', id).single()
    if (error) throw error
    return data
  },

  async updateStatus(id, newStatus, note = '') {
    const { data, error } = await supabase
      .from('leads').update({ status: newStatus, updated_at: new Date().toISOString() })
      .eq('id', id).select().single()
    if (error) throw error
    // Registrar en historial
    await supabase.from('lead_status_history').insert({
      lead_id: id, to_status: newStatus, note
    })
    return data
  },

  async create(payload) {
    const { data, error } = await supabase
      .from('leads').insert(payload).select().single()
    if (error) throw error
    return data
  },
}
EOF

cat > src/services/patients.service.js << 'EOF'
import { supabase } from './supabase.js'

export const patientsService = {
  async getAnimals(filters = {}) {
    let q = supabase.from('animals').select(`
      *, client:clients(id, name, phone, email)
    `).order('name')
    if (filters.client_id) q = q.eq('client_id', filters.client_id)
    if (filters.species)   q = q.eq('species', filters.species)
    const { data, error } = await q
    if (error) throw error
    return data
  },

  async getAnimalById(id) {
    const { data, error } = await supabase.from('animals').select(`
      *, client:clients(*),
      clinical_records(*, visit:visits(scheduled_at, status))
    `).eq('id', id).single()
    if (error) throw error
    return data
  },

  async getClients() {
    const { data, error } = await supabase
      .from('clients').select('*, animals(id, name, species)').order('name')
    if (error) throw error
    return data
  },
}
EOF

cat > src/services/inventory.service.js << 'EOF'
import { supabase } from './supabase.js'

export const inventoryService = {
  async getAll() {
    const { data, error } = await supabase
      .from('inventory').select('*').eq('active', true).order('name')
    if (error) throw error
    return data
  },

  async getLowStock() {
    const { data, error } = await supabase
      .from('inventory').select('*')
      .filter('stock', 'lte', supabase.raw('min_stock'))
      .eq('active', true)
    if (error) throw error
    return data
  },

  async upsert(payload) {
    const { data, error } = await supabase
      .from('inventory').upsert(payload).select().single()
    if (error) throw error
    return data
  },
}
EOF

cat > src/services/visits.service.js << 'EOF'
import { supabase } from './supabase.js'

export const visitsService = {
  async getByRange(from, to) {
    const { data, error } = await supabase
      .from('visits')
      .select(`*, client:clients(name,phone), animal:animals(name,species), assigned:users(name)`)
      .gte('scheduled_at', from).lte('scheduled_at', to)
      .order('scheduled_at')
    if (error) throw error
    return data
  },

  async getById(id) {
    const { data, error } = await supabase
      .from('visits').select(`
        *, client:clients(*), animal:animals(*), assigned:users(name),
        visit_procedures(*, procedure:procedures(*)),
        clinical_records(*)
      `).eq('id', id).single()
    if (error) throw error
    return data
  },
}
EOF

cat > src/services/notifications.service.js << 'EOF'
// Llama a Edge Functions de Supabase (no a APIs externas directamente)
import { supabase } from './supabase.js'

export const notificationsService = {
  async getWhatsAppPreview(leadId, template = 'initial_contact') {
    const { data, error } = await supabase.functions.invoke('whatsapp-preview', {
      body: { lead_id: leadId, template }
    })
    if (error) throw error
    return data
  },
}
EOF
log "Services generados"

# =============================================================================
# 11. Pinia Stores
# =============================================================================
cat > src/stores/auth.js << 'EOF'
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '@/services/supabase'

export const useAuthStore = defineStore('auth', () => {
  const user    = ref(null)
  const profile = ref(null)
  const loading = ref(true)

  const isAdmin    = computed(() => profile.value?.role === 'admin')
  const isTecnico  = computed(() => ['admin','tecnico'].includes(profile.value?.role))
  const isLoggedIn = computed(() => !!user.value)

  async function init() {
    loading.value = true
    const { data: { session } } = await supabase.auth.getSession()
    if (session?.user) {
      user.value = session.user
      await loadProfile()
    }
    // Escuchar cambios de sesión
    supabase.auth.onAuthStateChange(async (_event, session) => {
      user.value = session?.user ?? null
      if (user.value) await loadProfile()
      else profile.value = null
    })
    loading.value = false
  }

  async function loadProfile() {
    const { data } = await supabase
      .from('users').select('*').eq('id', user.value.id).single()
    profile.value = data
  }

  async function login(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
    user.value = data.user
    await loadProfile()
    return data
  }

  async function logout() {
    await supabase.auth.signOut()
    user.value = null
    profile.value = null
  }

  return { user, profile, loading, isAdmin, isTecnico, isLoggedIn, init, login, logout }
})
EOF

cat > src/stores/leads.js << 'EOF'
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { leadsService } from '@/services/leads.service'
import { LEAD_STATUS } from '@/utils/constants'

export const useLeadsStore = defineStore('leads', () => {
  const items   = ref([])
  const loading = ref(false)
  const error   = ref(null)

  const byStatus = computed(() => ({
    waiting:     items.value.filter(l => l.status === LEAD_STATUS.WAITING),
    in_progress: items.value.filter(l => l.status === LEAD_STATUS.IN_PROGRESS),
    done:        items.value.filter(l => l.status === LEAD_STATUS.DONE),
    cancelled:   items.value.filter(l => l.status === LEAD_STATUS.CANCELLED),
  }))

  const totalWaiting = computed(() => byStatus.value.waiting.length)

  async function fetchAll(filters = {}) {
    loading.value = true
    error.value   = null
    try {
      items.value = await leadsService.getAll(filters)
    } catch (e) {
      error.value = e.message
    } finally {
      loading.value = false
    }
  }

  async function updateStatus(id, newStatus, note = '') {
    try {
      const updated = await leadsService.updateStatus(id, newStatus, note)
      const idx = items.value.findIndex(l => l.id === id)
      if (idx !== -1) items.value[idx] = { ...items.value[idx], ...updated }
      return updated
    } catch (e) {
      error.value = e.message
      throw e
    }
  }

  return { items, loading, error, byStatus, totalWaiting, fetchAll, updateStatus }
})
EOF

cat > src/stores/agenda.js << 'EOF'
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { visitsService } from '@/services/visits.service'

export const useAgendaStore = defineStore('agenda', () => {
  const visits  = ref([])
  const loading = ref(false)
  const error   = ref(null)

  async function fetchByRange(from, to) {
    loading.value = true
    error.value   = null
    try {
      visits.value = await visitsService.getByRange(from, to)
    } catch (e) {
      error.value = e.message
    } finally {
      loading.value = false
    }
  }

  return { visits, loading, error, fetchByRange }
})
EOF

cat > src/stores/inventory.js << 'EOF'
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { inventoryService } from '@/services/inventory.service'

export const useInventoryStore = defineStore('inventory', () => {
  const items   = ref([])
  const loading = ref(false)
  const error   = ref(null)

  const lowStockItems = computed(() =>
    items.value.filter(i => i.stock <= i.min_stock)
  )
  const hasAlerts = computed(() => lowStockItems.value.length > 0)

  async function fetchAll() {
    loading.value = true
    error.value   = null
    try {
      items.value = await inventoryService.getAll()
    } catch (e) {
      error.value = e.message
    } finally {
      loading.value = false
    }
  }

  return { items, loading, error, lowStockItems, hasAlerts, fetchAll }
})
EOF

cat > src/stores/notifications.js << 'EOF'
import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useNotificationsStore = defineStore('notifications', () => {
  const toasts = ref([])

  function show(message, type = 'info', duration = 4000) {
    const id = Date.now()
    toasts.value.push({ id, message, type })
    setTimeout(() => dismiss(id), duration)
  }

  function dismiss(id) {
    toasts.value = toasts.value.filter(t => t.id !== id)
  }

  const success = (msg) => show(msg, 'success')
  const error   = (msg) => show(msg, 'error')
  const warning = (msg) => show(msg, 'warning')

  return { toasts, show, dismiss, success, error, warning }
})
EOF

cat > src/stores/patients.js << 'EOF'
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { patientsService } from '@/services/patients.service'

export const usePatientsStore = defineStore('patients', () => {
  const animals = ref([])
  const clients = ref([])
  const loading = ref(false)
  const error   = ref(null)

  async function fetchAnimals(filters = {}) {
    loading.value = true
    error.value   = null
    try {
      animals.value = await patientsService.getAnimals(filters)
    } catch (e) {
      error.value = e.message
    } finally {
      loading.value = false
    }
  }

  return { animals, clients, loading, error, fetchAnimals }
})
EOF
log "Pinia stores generados"

# =============================================================================
# 12. Composables
# =============================================================================
cat > src/composables/useAuth.js << 'EOF'
import { useAuthStore } from '@/stores/auth'
import { storeToRefs } from 'pinia'

export function useAuth() {
  const store = useAuthStore()
  const { user, profile, loading, isAdmin, isTecnico, isLoggedIn } = storeToRefs(store)
  return { user, profile, loading, isAdmin, isTecnico, isLoggedIn,
           login: store.login, logout: store.logout }
}
EOF

cat > src/composables/useToast.js << 'EOF'
import { useNotificationsStore } from '@/stores/notifications'

export function useToast() {
  const store = useNotificationsStore()
  return {
    success: store.success,
    error:   store.error,
    warning: store.warning,
    show:    store.show,
  }
}
EOF

cat > src/composables/useLeads.js << 'EOF'
import { useLeadsStore } from '@/stores/leads'
import { storeToRefs } from 'pinia'

export function useLeads() {
  const store = useLeadsStore()
  const { items, loading, error, byStatus, totalWaiting } = storeToRefs(store)
  return { items, loading, error, byStatus, totalWaiting,
           fetchAll: store.fetchAll, updateStatus: store.updateStatus }
}
EOF

cat > src/composables/useWhatsApp.js << 'EOF'
import { buildWALink, buildWALinkFromLead, WA_TEMPLATES } from '@/utils/whatsapp'
import { ref } from 'vue'

export function useWhatsApp() {
  const copied = ref(false)

  async function copyText(text) {
    await navigator.clipboard.writeText(text)
    copied.value = true
    setTimeout(() => (copied.value = false), 2000)
  }

  function openLink(url) {
    window.open(url, '_blank')
  }

  return { copied, copyText, openLink, buildWALink, buildWALinkFromLead, WA_TEMPLATES }
}
EOF

cat > src/composables/useGsap.js << 'EOF'
import { gsap } from 'gsap'
import { onMounted, onBeforeUnmount, ref } from 'vue'

export function useGsap(targetRef) {
  const ctx = ref(null)

  function fadeIn(el, vars = {}) {
    return gsap.from(el, { opacity: 0, duration: 0.4, ease: 'power2.out', ...vars })
  }

  function slideUp(el, vars = {}) {
    return gsap.from(el, { opacity: 0, y: 20, duration: 0.4, ease: 'power2.out', ...vars })
  }

  function staggerIn(els, vars = {}) {
    return gsap.from(els, { opacity: 0, y: 16, duration: 0.35,
      stagger: 0.07, ease: 'power2.out', ...vars })
  }

  onBeforeUnmount(() => ctx.value?.revert())

  return { fadeIn, slideUp, staggerIn }
}
EOF
log "Composables generados"

# =============================================================================
# 13. Router
# =============================================================================
cat > src/router/index.js << 'EOF'
import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

// Public views
const LandingView      = () => import('@/views/public/LandingView.vue')
const SolicitudView    = () => import('@/views/public/SolicitudView.vue')
const ConfirmacionView = () => import('@/views/public/ConfirmacionView.vue')
const LoginView        = () => import('@/views/auth/LoginView.vue')

// App views (lazy loaded)
const DashboardView      = () => import('@/views/app/DashboardView.vue')
const LeadsView          = () => import('@/views/app/LeadsView.vue')
const LeadDetailView     = () => import('@/views/app/LeadDetailView.vue')
const AgendaView         = () => import('@/views/app/AgendaView.vue')
const VisitaDetailView   = () => import('@/views/app/VisitaDetailView.vue')
const PacientesView      = () => import('@/views/app/PacientesView.vue')
const PacienteDetailView = () => import('@/views/app/PacienteDetailView.vue')
const InventarioView     = () => import('@/views/app/InventarioView.vue')
const ProcedimientosView = () => import('@/views/app/ProcedimientosView.vue')
const ReportesView       = () => import('@/views/app/ReportesView.vue')
const ConfiguracionView  = () => import('@/views/app/ConfiguracionView.vue')

const PUBLIC_PATHS = ['/', '/solicitar', '/confirmacion', '/login']

const router = createRouter({
  history: createWebHistory(),
  routes: [
    // Public
    { path: '/',             component: LandingView,      meta: { layout: 'public' } },
    { path: '/solicitar',    component: SolicitudView,    meta: { layout: 'public' } },
    { path: '/confirmacion', component: ConfirmacionView, meta: { layout: 'public' } },
    { path: '/login',        component: LoginView,        meta: { layout: 'none' } },

    // App (protected)
    { path: '/app',          redirect: '/app/dashboard' },
    { path: '/app/dashboard',          component: DashboardView,      meta: { requiresAuth: true } },
    { path: '/app/leads',              component: LeadsView,          meta: { requiresAuth: true } },
    { path: '/app/leads/:id',          component: LeadDetailView,     meta: { requiresAuth: true } },
    { path: '/app/agenda',             component: AgendaView,         meta: { requiresAuth: true } },
    { path: '/app/visitas/:id',        component: VisitaDetailView,   meta: { requiresAuth: true } },
    { path: '/app/pacientes',          component: PacientesView,      meta: { requiresAuth: true } },
    { path: '/app/pacientes/:id',      component: PacienteDetailView, meta: { requiresAuth: true } },
    { path: '/app/inventario',         component: InventarioView,     meta: { requiresAuth: true } },
    { path: '/app/procedimientos',     component: ProcedimientosView, meta: { requiresAuth: true } },
    { path: '/app/reportes',           component: ReportesView,       meta: { requiresAuth: true } },
    { path: '/app/configuracion',      component: ConfiguracionView,  meta: { requiresAuth: true } },

    // 404
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
  scrollBehavior: () => ({ top: 0 }),
})

router.beforeEach(async (to) => {
  const authStore = useAuthStore()
  if (authStore.loading) await authStore.init()

  if (to.meta.requiresAuth && !authStore.isLoggedIn) return '/login'
  if (to.path === '/login' && authStore.isLoggedIn)  return '/app/dashboard'
})

export default router
EOF
log "Router generado"

# =============================================================================
# 14. Layouts
# =============================================================================
cat > src/layouts/PublicLayout.vue << 'EOF'
<script setup>
// Layout para páginas públicas (landing, formulario)
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
    <slot />
  </div>
</template>
EOF

cat > src/layouts/AppLayout.vue << 'EOF'
<script setup>
import { ref } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { useInventoryStore } from '@/stores/inventory'
import { useLeadsStore } from '@/stores/leads'
import { storeToRefs } from 'pinia'

const route         = useRoute()
const { profile, logout } = useAuth()
const inventoryStore = useInventoryStore()
const leadsStore     = useLeadsStore()
const { hasAlerts }   = storeToRefs(inventoryStore)
const { totalWaiting } = storeToRefs(leadsStore)

const sidebarOpen = ref(false)

const navItems = [
  { path: '/app/dashboard',      label: 'Dashboard',      icon: '📊' },
  { path: '/app/leads',          label: 'Leads',          icon: '📋' },
  { path: '/app/agenda',         label: 'Agenda',         icon: '📅' },
  { path: '/app/pacientes',      label: 'Pacientes',      icon: '🐾' },
  { path: '/app/inventario',     label: 'Inventario',     icon: '📦' },
  { path: '/app/procedimientos', label: 'Procedimientos', icon: '🩺' },
  { path: '/app/reportes',       label: 'Reportes',       icon: '📈' },
  { path: '/app/configuracion',  label: 'Configuración',  icon: '⚙️' },
]

function isActive(path) {
  return route.path === path || route.path.startsWith(path + '/')
}
</script>

<template>
  <div class="flex h-screen bg-slate-900 overflow-hidden">
    <!-- Sidebar -->
    <aside class="w-64 flex-shrink-0 bg-slate-800/80 border-r border-slate-700/60 flex flex-col">
      <!-- Logo -->
      <div class="h-16 flex items-center px-6 border-b border-slate-700/60">
        <span class="text-xl font-bold text-white">🐾 VetDesk</span>
      </div>

      <!-- Nav -->
      <nav class="flex-1 px-3 py-4 overflow-y-auto space-y-0.5">
        <RouterLink
          v-for="item in navItems" :key="item.path"
          :to="item.path"
          class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors"
          :class="isActive(item.path)
            ? 'bg-brand-600/20 text-brand-400'
            : 'text-slate-400 hover:text-slate-100 hover:bg-slate-700/60'"
        >
          <span class="text-base">{{ item.icon }}</span>
          <span>{{ item.label }}</span>
          <!-- Badge para leads en espera -->
          <span v-if="item.path === '/app/leads' && totalWaiting > 0"
            class="ml-auto badge bg-amber-500/20 text-amber-400 border border-amber-500/30">
            {{ totalWaiting }}
          </span>
          <!-- Badge para alertas de stock -->
          <span v-if="item.path === '/app/inventario' && hasAlerts"
            class="ml-auto w-2 h-2 rounded-full bg-red-500 animate-pulse" />
        </RouterLink>
      </nav>

      <!-- User -->
      <div class="p-4 border-t border-slate-700/60">
        <div class="flex items-center gap-3">
          <div class="w-8 h-8 rounded-full bg-brand-600 flex items-center justify-center text-white text-sm font-bold">
            {{ profile?.name?.charAt(0) || '?' }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-slate-200 truncate">{{ profile?.name }}</p>
            <p class="text-xs text-slate-500 capitalize">{{ profile?.role }}</p>
          </div>
          <button @click="logout" class="btn-ghost !px-2 !py-1 text-xs">Salir</button>
        </div>
      </div>
    </aside>

    <!-- Main content -->
    <main class="flex-1 overflow-y-auto">
      <RouterView />
    </main>
  </div>
</template>
EOF
log "Layouts generados"

# =============================================================================
# 15. Componentes UI base
# =============================================================================
cat > src/components/ui/BaseButton.vue << 'EOF'
<script setup>
defineProps({
  variant:  { type: String, default: 'primary' }, // primary | secondary | ghost | danger
  size:     { type: String, default: 'md' },       // sm | md | lg
  loading:  { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
  type:     { type: String, default: 'button' },
})
</script>
<template>
  <button
    :type="type"
    :disabled="disabled || loading"
    :class="[
      variant === 'primary'   && 'btn-primary',
      variant === 'secondary' && 'btn-secondary',
      variant === 'ghost'     && 'btn-ghost',
      variant === 'danger'    && 'inline-flex items-center gap-2 px-4 py-2.5 rounded-lg bg-red-600 hover:bg-red-500 text-white text-sm font-medium transition-colors disabled:opacity-50',
      size === 'sm'  && '!text-xs !px-3 !py-1.5',
      size === 'lg'  && '!text-base !px-6 !py-3',
    ]"
  >
    <span v-if="loading" class="spinner !w-4 !h-4" />
    <slot />
  </button>
</template>
EOF

cat > src/components/ui/BaseInput.vue << 'EOF'
<script setup>
defineProps({
  modelValue: { type: [String, Number], default: '' },
  label:      { type: String, default: '' },
  placeholder:{ type: String, default: '' },
  type:       { type: String, default: 'text' },
  error:      { type: String, default: '' },
  required:   { type: Boolean, default: false },
  disabled:   { type: Boolean, default: false },
})
defineEmits(['update:modelValue'])
</script>
<template>
  <div class="w-full">
    <label v-if="label" class="label-base">
      {{ label }} <span v-if="required" class="text-red-400">*</span>
    </label>
    <input
      :type="type"
      :value="modelValue"
      :placeholder="placeholder"
      :disabled="disabled"
      class="input-base"
      :class="error && 'border-red-500 focus:ring-red-500/50'"
      @input="$emit('update:modelValue', $event.target.value)"
    />
    <p v-if="error" class="mt-1 text-xs text-red-400">{{ error }}</p>
  </div>
</template>
EOF

cat > src/components/ui/BaseSelect.vue << 'EOF'
<script setup>
defineProps({
  modelValue: { type: [String, Number], default: '' },
  label:      { type: String, default: '' },
  options:    { type: Array, default: () => [] }, // [{ value, label }]
  placeholder:{ type: String, default: 'Seleccionar...' },
  error:      { type: String, default: '' },
  required:   { type: Boolean, default: false },
})
defineEmits(['update:modelValue'])
</script>
<template>
  <div class="w-full">
    <label v-if="label" class="label-base">
      {{ label }} <span v-if="required" class="text-red-400">*</span>
    </label>
    <select
      :value="modelValue"
      class="input-base"
      :class="error && 'border-red-500'"
      @change="$emit('update:modelValue', $event.target.value)"
    >
      <option value="" disabled>{{ placeholder }}</option>
      <option v-for="opt in options" :key="opt.value" :value="opt.value">
        {{ opt.label }}
      </option>
    </select>
    <p v-if="error" class="mt-1 text-xs text-red-400">{{ error }}</p>
  </div>
</template>
EOF

cat > src/components/ui/BaseModal.vue << 'EOF'
<script setup>
import { onMounted, onBeforeUnmount } from 'vue'
defineProps({
  title:     { type: String, default: '' },
  size:      { type: String, default: 'md' }, // sm | md | lg | xl
})
const emit = defineEmits(['close'])
function onKeydown(e) { if (e.key === 'Escape') emit('close') }
onMounted(()       => document.addEventListener('keydown', onKeydown))
onBeforeUnmount(() => document.removeEventListener('keydown', onKeydown))
</script>
<template>
  <Teleport to="body">
    <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" @click="$emit('close')" />
      <div
        class="relative card p-6 w-full shadow-2xl"
        :class="{
          'max-w-sm':  size === 'sm',
          'max-w-md':  size === 'md',
          'max-w-lg':  size === 'lg',
          'max-w-2xl': size === 'xl',
        }"
      >
        <div v-if="title" class="flex items-center justify-between mb-5">
          <h2 class="text-lg font-semibold text-white">{{ title }}</h2>
          <button @click="$emit('close')" class="btn-ghost !p-1.5 text-slate-400">✕</button>
        </div>
        <slot />
      </div>
    </div>
  </Teleport>
</template>
EOF

cat > src/components/ui/BaseBadge.vue << 'EOF'
<script setup>
defineProps({
  variant: { type: String, default: 'default' }, // default | success | warning | danger | info
})
const classes = {
  default: 'bg-slate-500/20 text-slate-400 border border-slate-500/30',
  success: 'bg-brand-500/20 text-brand-400 border border-brand-500/30',
  warning: 'bg-amber-500/20 text-amber-400 border border-amber-500/30',
  danger:  'bg-red-500/20 text-red-400 border border-red-500/30',
  info:    'bg-blue-500/20 text-blue-400 border border-blue-500/30',
}
</script>
<template>
  <span class="badge" :class="classes[variant] || classes.default"><slot /></span>
</template>
EOF

cat > src/components/ui/BaseCard.vue << 'EOF'
<script setup>
defineProps({
  padding: { type: String, default: 'p-5' },
  hover:   { type: Boolean, default: false },
})
</script>
<template>
  <div class="card" :class="[padding, hover && 'hover:border-slate-600 transition-colors cursor-pointer']">
    <slot />
  </div>
</template>
EOF

cat > src/components/ui/BaseToast.vue << 'EOF'
<script setup>
import { useNotificationsStore } from '@/stores/notifications'
import { storeToRefs } from 'pinia'
const { toasts } = storeToRefs(useNotificationsStore())
const { dismiss } = useNotificationsStore()
const icons = { success: '✓', error: '✕', warning: '⚠', info: 'ℹ' }
const colors = {
  success: 'bg-brand-600 border-brand-500',
  error:   'bg-red-700 border-red-600',
  warning: 'bg-amber-600 border-amber-500',
  info:    'bg-blue-700 border-blue-600',
}
</script>
<template>
  <Teleport to="body">
    <div class="fixed bottom-5 right-5 z-[100] flex flex-col gap-2 max-w-sm w-full px-4">
      <TransitionGroup name="toast" tag="div" class="flex flex-col gap-2">
        <div
          v-for="toast in toasts" :key="toast.id"
          class="flex items-start gap-3 px-4 py-3 rounded-lg border text-sm text-white shadow-xl"
          :class="colors[toast.type] || colors.info"
        >
          <span class="font-bold">{{ icons[toast.type] || 'ℹ' }}</span>
          <span class="flex-1">{{ toast.message }}</span>
          <button @click="dismiss(toast.id)" class="opacity-60 hover:opacity-100">✕</button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>
<style scoped>
.toast-enter-active, .toast-leave-active { transition: all 0.3s ease; }
.toast-enter-from  { opacity: 0; transform: translateX(100%); }
.toast-leave-to    { opacity: 0; transform: translateX(100%); }
</style>
EOF
log "Componentes UI base generados"

# =============================================================================
# 16. main.js y App.vue
# =============================================================================
cat > src/main.js << 'EOF'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { gsap } from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

import App from './App.vue'
import router from './router'

import './assets/styles/main.css'
import './assets/styles/animations.css'

// GSAP plugins
gsap.registerPlugin(ScrollTrigger)

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.mount('#app')
EOF

cat > src/App.vue << 'EOF'
<script setup>
import { onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import AppLayout    from '@/layouts/AppLayout.vue'
import PublicLayout from '@/layouts/PublicLayout.vue'
import BaseToast    from '@/components/ui/BaseToast.vue'

const route     = useRoute()
const authStore = useAuthStore()

onMounted(() => authStore.init())
</script>

<template>
  <AppLayout    v-if="route.meta.requiresAuth">
    <RouterView />
  </AppLayout>
  <PublicLayout v-else-if="route.meta.layout === 'public'">
    <RouterView />
  </PublicLayout>
  <RouterView v-else />

  <BaseToast />
</template>
EOF
log "main.js y App.vue generados"

# =============================================================================
# 17. Views — stubs funcionales
# =============================================================================
generate_view() {
  local path="$1" title="$2" icon="$3"
  cat > "$path" << VEOF
<script setup>
// TODO: Implementar ${title}
</script>
<template>
  <div class="p-6">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-white">${icon} ${title}</h1>
      <p class="text-slate-400 text-sm mt-1">Esta vista está lista para implementar.</p>
    </div>
    <div class="card p-8 text-center text-slate-500">
      <p class="text-4xl mb-3">${icon}</p>
      <p class="font-medium">Módulo ${title} — por implementar</p>
    </div>
  </div>
</template>
VEOF
}

# Public views
cat > src/views/public/LandingView.vue << 'EOF'
<script setup>
import { RouterLink } from 'vue-router'
</script>
<template>
  <div class="min-h-screen flex flex-col items-center justify-center px-4 text-center">
    <h1 class="text-5xl font-bold text-white mb-4">🐾 VetDesk</h1>
    <p class="text-xl text-slate-400 mb-8 max-w-lg">
      Atención veterinaria a domicilio. Rápida, confiable y sin complicaciones.
    </p>
    <RouterLink to="/solicitar" class="btn-primary text-lg px-8 py-3">
      Solicitar visita
    </RouterLink>
  </div>
</template>
EOF

cat > src/views/public/SolicitudView.vue << 'EOF'
<script setup>
import { ref } from 'vue'
import BaseInput  from '@/components/ui/BaseInput.vue'
import BaseSelect from '@/components/ui/BaseSelect.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import { ANIMAL_SPECIES, SERVICE_TYPES } from '@/utils/constants'
import { normalizePhone, isValidChilePhone } from '@/utils/validators'
import { useRouter } from 'vue-router'

const router  = useRouter()
const step    = ref(1)
const loading = ref(false)
const TOTAL_STEPS = 4

const form = ref({
  client_name: '', client_phone: '', client_email: '',
  region: '', comuna: '', address: '',
  animal_name: '', animal_species: '', animal_breed: '', animal_sex: '',
  service_type: '', description: '', priority: 'normal',
})
const errors = ref({})

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
      { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) }
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
  <div class="min-h-screen flex items-center justify-center px-4 py-12">
    <div class="w-full max-w-lg">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-white">🐾 Solicitar visita</h1>
        <div class="flex justify-center gap-2 mt-4">
          <div v-for="i in TOTAL_STEPS" :key="i"
            class="h-1.5 rounded-full transition-all duration-300"
            :class="[i <= step ? 'bg-brand-500 w-8' : 'bg-slate-700 w-4']" />
        </div>
        <p class="text-slate-500 text-sm mt-2">Paso {{ step }} de {{ TOTAL_STEPS }}</p>
      </div>

      <div class="card p-6 space-y-4">
        <!-- Paso 1 -->
        <template v-if="step === 1">
          <h2 class="text-lg font-semibold text-white mb-2">Sobre ti</h2>
          <BaseInput v-model="form.client_name"  label="Nombre completo" required :error="errors.client_name" />
          <BaseInput v-model="form.client_phone" label="Teléfono" placeholder="+569..." required :error="errors.client_phone" />
          <BaseInput v-model="form.client_email" label="Email" type="email" />
          <BaseInput v-model="form.region"   label="Región"   required :error="errors.region" />
          <BaseInput v-model="form.comuna"   label="Comuna"   required :error="errors.comuna" />
          <BaseInput v-model="form.address"  label="Dirección" required :error="errors.address" />
        </template>

        <!-- Paso 2 -->
        <template v-else-if="step === 2">
          <h2 class="text-lg font-semibold text-white mb-2">Tu mascota</h2>
          <BaseInput  v-model="form.animal_name"    label="Nombre del animal" required :error="errors.animal_name" />
          <BaseSelect v-model="form.animal_species" label="Especie" required :options="ANIMAL_SPECIES" :error="errors.animal_species" />
          <BaseInput  v-model="form.animal_breed"   label="Raza (opcional)" />
          <BaseSelect v-model="form.animal_sex" label="Sexo"
            :options="[{value:'macho',label:'Macho'},{value:'hembra',label:'Hembra'},{value:'desconocido',label:'Desconocido'}]" />
        </template>

        <!-- Paso 3 -->
        <template v-else-if="step === 3">
          <h2 class="text-lg font-semibold text-white mb-2">¿Qué necesitas?</h2>
          <BaseSelect v-model="form.service_type" label="Tipo de servicio" required :options="SERVICE_TYPES" :error="errors.service_type" />
          <div>
            <label class="label-base">Descripción del caso <span class="text-red-400">*</span></label>
            <textarea v-model="form.description" rows="4" class="input-base resize-none"
              placeholder="Describe el caso con al menos 20 caracteres..." />
            <p v-if="errors.description" class="mt-1 text-xs text-red-400">{{ errors.description }}</p>
          </div>
          <BaseSelect v-model="form.priority" label="Urgencia"
            :options="[{value:'normal',label:'Normal'},{value:'urgent',label:'Urgente'}]" />
        </template>

        <!-- Paso 4 -->
        <template v-else>
          <h2 class="text-lg font-semibold text-white mb-2">Confirmar solicitud</h2>
          <div class="space-y-3 text-sm">
            <div class="bg-slate-700/40 rounded-lg p-3 space-y-1">
              <p class="text-slate-400 text-xs uppercase tracking-wider mb-2">Datos personales</p>
              <p><span class="text-slate-400">Nombre:</span> <span class="text-white">{{ form.client_name }}</span></p>
              <p><span class="text-slate-400">Teléfono:</span> <span class="text-white">{{ form.client_phone }}</span></p>
              <p><span class="text-slate-400">Dirección:</span> <span class="text-white">{{ form.comuna }}, {{ form.region }}</span></p>
            </div>
            <div class="bg-slate-700/40 rounded-lg p-3 space-y-1">
              <p class="text-slate-400 text-xs uppercase tracking-wider mb-2">Mascota</p>
              <p><span class="text-slate-400">Nombre:</span> <span class="text-white">{{ form.animal_name }}</span></p>
              <p><span class="text-slate-400">Especie:</span> <span class="text-white capitalize">{{ form.animal_species }}</span></p>
            </div>
            <div class="bg-slate-700/40 rounded-lg p-3 space-y-1">
              <p class="text-slate-400 text-xs uppercase tracking-wider mb-2">Solicitud</p>
              <p><span class="text-slate-400">Servicio:</span> <span class="text-white capitalize">{{ form.service_type?.replace('_',' ') }}</span></p>
              <p><span class="text-slate-400">Descripción:</span> <span class="text-white">{{ form.description }}</span></p>
            </div>
          </div>
          <p v-if="errors.submit" class="text-red-400 text-sm">{{ errors.submit }}</p>
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
EOF

cat > src/views/public/ConfirmacionView.vue << 'EOF'
<script setup>
import { RouterLink } from 'vue-router'
</script>
<template>
  <div class="min-h-screen flex items-center justify-center px-4 text-center">
    <div class="max-w-md">
      <div class="text-6xl mb-6">✅</div>
      <h1 class="text-3xl font-bold text-white mb-3">¡Solicitud enviada!</h1>
      <p class="text-slate-400 mb-8">
        Recibimos tu solicitud. Nos pondremos en contacto contigo a la brevedad.
      </p>
      <RouterLink to="/" class="btn-secondary">Volver al inicio</RouterLink>
    </div>
  </div>
</template>
EOF

# Auth
cat > src/views/auth/LoginView.vue << 'EOF'
<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { useToast } from '@/composables/useToast'
import BaseInput  from '@/components/ui/BaseInput.vue'
import BaseButton from '@/components/ui/BaseButton.vue'

const router  = useRouter()
const { login } = useAuth()
const toast   = useToast()

const email    = ref('')
const password = ref('')
const loading  = ref(false)
const error    = ref('')

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    await login(email.value, password.value)
    router.push('/app/dashboard')
  } catch (e) {
    error.value = 'Credenciales incorrectas.'
    toast.error('Error al iniciar sesión')
  } finally {
    loading.value = false
  }
}
</script>
<template>
  <div class="min-h-screen bg-slate-900 flex items-center justify-center px-4">
    <div class="w-full max-w-sm">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-white">🐾 VetDesk</h1>
        <p class="text-slate-400 mt-2">Panel de administración</p>
      </div>
      <div class="card p-6 space-y-4">
        <BaseInput v-model="email"    label="Email"      type="email"    required />
        <BaseInput v-model="password" label="Contraseña" type="password" required />
        <p v-if="error" class="text-red-400 text-sm">{{ error }}</p>
        <BaseButton class="w-full" :loading="loading" @click="handleLogin">
          Ingresar
        </BaseButton>
      </div>
    </div>
  </div>
</template>
EOF

# App views — stubs
generate_view "src/views/app/DashboardView.vue"      "Dashboard"      "📊"
generate_view "src/views/app/LeadsView.vue"          "Leads"          "📋"
generate_view "src/views/app/LeadDetailView.vue"     "Detalle de Lead" "📋"
generate_view "src/views/app/AgendaView.vue"         "Agenda"         "📅"
generate_view "src/views/app/VisitaDetailView.vue"   "Detalle de Visita" "📅"
generate_view "src/views/app/PacientesView.vue"      "Pacientes"      "🐾"
generate_view "src/views/app/PacienteDetailView.vue" "Ficha de Paciente" "🐾"
generate_view "src/views/app/InventarioView.vue"     "Inventario"     "📦"
generate_view "src/views/app/ProcedimientosView.vue" "Procedimientos" "🩺"
generate_view "src/views/app/ReportesView.vue"       "Reportes"       "📈"
generate_view "src/views/app/ConfiguracionView.vue"  "Configuración"  "⚙️"

log "Views generados"

# =============================================================================
# 18. Supabase migrations y Edge Functions
# =============================================================================
mkdir -p supabase/migrations supabase/functions/{create-lead,close-visit,telegram-webhook,whatsapp-preview,send-email}

cat > supabase/migrations/001_initial_schema.sql << 'EOF'
-- VetDesk — Schema inicial
-- Ejecutar en orden: 001 → 002 → 003 → 004

-- Extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla users (extiende auth.users de Supabase)
CREATE TABLE users (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  email       TEXT NOT NULL UNIQUE,
  role        TEXT NOT NULL CHECK (role IN ('admin', 'tecnico', 'asistente')),
  phone       TEXT,
  telegram_id BIGINT UNIQUE,
  active      BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- clients
CREATE TABLE clients (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT NOT NULL,
  phone      TEXT NOT NULL,
  email      TEXT,
  region     TEXT,
  comuna     TEXT,
  address    TEXT,
  notes      TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- animals
CREATE TABLE animals (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id   UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  species     TEXT NOT NULL CHECK (species IN ('perro','gato','ave','gallina','caballo','bovino','otro')),
  breed       TEXT,
  birth_date  DATE,
  sex         TEXT CHECK (sex IN ('macho','hembra','desconocido')),
  weight_kg   NUMERIC(5,2),
  photo_url   TEXT,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- leads
CREATE TABLE leads (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id           UUID REFERENCES clients(id),
  animal_id           UUID REFERENCES animals(id),
  assigned_to         UUID REFERENCES users(id),
  status              TEXT NOT NULL DEFAULT 'waiting'
                        CHECK (status IN ('waiting','in_progress','done','cancelled')),
  service_type        TEXT NOT NULL,
  description         TEXT,
  priority            TEXT DEFAULT 'normal' CHECK (priority IN ('low','normal','high','urgent')),
  confidence_score    INTEGER DEFAULT 50 CHECK (confidence_score BETWEEN 0 AND 100),
  source              TEXT DEFAULT 'web_form'
                        CHECK (source IN ('web_form','telegram','whatsapp','phone','referral')),
  inventory_checked   BOOLEAN DEFAULT FALSE,
  inventory_ok        BOOLEAN,
  telegram_message_id BIGINT,
  notes               TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- lead_status_history
CREATE TABLE lead_status_history (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id     UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  from_status TEXT,
  to_status   TEXT NOT NULL,
  changed_by  UUID REFERENCES users(id),
  note        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- visits
CREATE TABLE visits (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id      UUID NOT NULL REFERENCES leads(id),
  animal_id    UUID NOT NULL REFERENCES animals(id),
  client_id    UUID NOT NULL REFERENCES clients(id),
  assigned_to  UUID NOT NULL REFERENCES users(id),
  scheduled_at TIMESTAMPTZ NOT NULL,
  duration_min INTEGER DEFAULT 60,
  status       TEXT NOT NULL DEFAULT 'scheduled'
                 CHECK (status IN ('scheduled','confirmed','in_progress','completed','cancelled')),
  address      TEXT NOT NULL,
  notes        TEXT,
  completed_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- procedures
CREATE TABLE procedures (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL,
  description  TEXT,
  category     TEXT NOT NULL CHECK (category IN ('vacunacion','desparasitacion','chequeo','receta','corte_pelo','atencion_domicilio','otro')),
  duration_min INTEGER DEFAULT 30,
  base_price   NUMERIC(10,2),
  active       BOOLEAN DEFAULT TRUE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- inventory
CREATE TABLE inventory (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name           TEXT NOT NULL,
  description    TEXT,
  category       TEXT NOT NULL CHECK (category IN ('vacuna','farmaco','insumo','herramienta')),
  stock          NUMERIC(10,2) NOT NULL DEFAULT 0,
  min_stock      NUMERIC(10,2) NOT NULL DEFAULT 0,
  unit           TEXT NOT NULL DEFAULT 'unidad',
  cost_per_unit  NUMERIC(10,2),
  manual_url     TEXT,
  supplier_name  TEXT,
  supplier_phone TEXT,
  supplier_email TEXT,
  active         BOOLEAN DEFAULT TRUE,
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  updated_at     TIMESTAMPTZ DEFAULT NOW()
);

-- procedure_inventory (N:M)
CREATE TABLE procedure_inventory (
  procedure_id UUID NOT NULL REFERENCES procedures(id) ON DELETE CASCADE,
  inventory_id UUID NOT NULL REFERENCES inventory(id) ON DELETE CASCADE,
  quantity     NUMERIC(10,3) NOT NULL DEFAULT 1,
  notes        TEXT,
  PRIMARY KEY (procedure_id, inventory_id)
);

-- visit_procedures
CREATE TABLE visit_procedures (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  visit_id     UUID NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
  procedure_id UUID NOT NULL REFERENCES procedures(id),
  executed     BOOLEAN DEFAULT FALSE,
  notes        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- inventory_usage
CREATE TABLE inventory_usage (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  visit_id      UUID NOT NULL REFERENCES visits(id),
  inventory_id  UUID NOT NULL REFERENCES inventory(id),
  quantity_used NUMERIC(10,3) NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- clinical_records
CREATE TABLE clinical_records (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  visit_id       UUID NOT NULL UNIQUE REFERENCES visits(id),
  animal_id      UUID NOT NULL REFERENCES animals(id),
  lead_id        UUID REFERENCES leads(id),
  weight_kg      NUMERIC(5,2),
  temperature_c  NUMERIC(4,1),
  diagnosis      TEXT,
  treatment      TEXT,
  prescriptions  TEXT,
  observations   TEXT,
  next_visit_rec TEXT,
  created_by     UUID REFERENCES users(id),
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  updated_at     TIMESTAMPTZ DEFAULT NOW()
);

-- audit_log
CREATE TABLE audit_log (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID REFERENCES users(id),
  entity     TEXT NOT NULL,
  entity_id  UUID NOT NULL,
  action     TEXT NOT NULL,
  payload    JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar RLS en todas las tablas
ALTER TABLE users              ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients            ENABLE ROW LEVEL SECURITY;
ALTER TABLE animals            ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads              ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE visits             ENABLE ROW LEVEL SECURITY;
ALTER TABLE procedures         ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory          ENABLE ROW LEVEL SECURITY;
ALTER TABLE procedure_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE visit_procedures   ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_usage    ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinical_records   ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log          ENABLE ROW LEVEL SECURITY;
EOF

cat > supabase/migrations/002_rls_policies.sql << 'EOF'
-- RLS Policies para VetDesk
-- IMPORTANTE: Ejecutar DESPUÉS de 001_initial_schema.sql

-- Helper: obtener rol del usuario actual
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT AS $$
  SELECT role FROM users WHERE id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- === USERS ===
CREATE POLICY "users_select_own" ON users FOR SELECT
  USING (id = auth.uid() OR get_user_role() = 'admin');

CREATE POLICY "users_update_own" ON users FOR UPDATE
  USING (id = auth.uid());

-- === CLIENTS ===
CREATE POLICY "clients_all_authenticated" ON clients FOR ALL
  USING (auth.role() = 'authenticated');

-- === ANIMALS ===
CREATE POLICY "animals_all_authenticated" ON animals FOR ALL
  USING (auth.role() = 'authenticated');

-- === LEADS ===
CREATE POLICY "leads_select" ON leads FOR SELECT
  USING (get_user_role() = 'admin' OR assigned_to = auth.uid());

CREATE POLICY "leads_insert" ON leads FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "leads_update" ON leads FOR UPDATE
  USING (get_user_role() = 'admin' OR assigned_to = auth.uid());

-- === LEAD STATUS HISTORY ===
CREATE POLICY "lead_history_select" ON lead_status_history FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "lead_history_insert" ON lead_status_history FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- === VISITS ===
CREATE POLICY "visits_select" ON visits FOR SELECT
  USING (get_user_role() = 'admin' OR assigned_to = auth.uid());

CREATE POLICY "visits_insert_update" ON visits FOR ALL
  USING (get_user_role() IN ('admin', 'tecnico'));

-- === PROCEDURES ===
CREATE POLICY "procedures_read" ON procedures FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "procedures_write" ON procedures FOR ALL
  USING (get_user_role() = 'admin');

-- === INVENTORY ===
CREATE POLICY "inventory_read" ON inventory FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "inventory_write" ON inventory FOR ALL
  USING (get_user_role() = 'admin');

-- === CLINICAL RECORDS ===
CREATE POLICY "clinical_read" ON clinical_records FOR SELECT
  USING (
    get_user_role() = 'admin'
    OR EXISTS (
      SELECT 1 FROM visits v
      WHERE v.id = clinical_records.visit_id AND v.assigned_to = auth.uid()
    )
  );

CREATE POLICY "clinical_insert" ON clinical_records FOR INSERT
  WITH CHECK (get_user_role() IN ('admin', 'tecnico'));

-- === AUDIT LOG ===
CREATE POLICY "audit_read" ON audit_log FOR SELECT
  USING (get_user_role() = 'admin');

-- Solo Edge Functions (service_role) pueden insertar
CREATE POLICY "audit_insert_service" ON audit_log FOR INSERT
  WITH CHECK (get_user_role() IS NOT NULL);
EOF

cat > supabase/migrations/003_functions.sql << 'EOF'
-- Funciones SQL de VetDesk

-- updated_at automático
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar a todas las tablas con updated_at
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['users','clients','animals','leads','visits','procedures','inventory','clinical_records'] LOOP
    EXECUTE format('
      CREATE TRIGGER set_updated_at BEFORE UPDATE ON %I
      FOR EACH ROW EXECUTE FUNCTION handle_updated_at()', t);
  END LOOP;
END;
$$;
EOF

cat > supabase/migrations/004_triggers.sql << 'EOF'
-- Trigger: registrar cambio de estado de lead en historial
CREATE OR REPLACE FUNCTION log_lead_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO lead_status_history (lead_id, from_status, to_status, changed_by)
    VALUES (NEW.id, OLD.status, NEW.status, auth.uid());
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER lead_status_history_trigger
  AFTER UPDATE ON leads
  FOR EACH ROW EXECUTE FUNCTION log_lead_status_change();
EOF

# Edge Function stubs
cat > supabase/functions/create-lead/index.ts << 'EOF'
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const body = await req.json()

    // 1. Validar campos requeridos
    const required = ['client_name','client_phone','region','comuna','address','animal_name','animal_species','service_type','description']
    for (const field of required) {
      if (!body[field]) return new Response(JSON.stringify({ error: `Campo requerido: ${field}` }), { status: 400, headers: corsHeaders })
    }

    // 2. Buscar o crear cliente
    let clientId: string
    const { data: existing } = await supabase.from('clients').select('id').eq('phone', body.client_phone).single()
    if (existing) {
      clientId = existing.id
    } else {
      const { data: newClient, error } = await supabase.from('clients').insert({
        name: body.client_name, phone: body.client_phone, email: body.client_email,
        region: body.region, comuna: body.comuna, address: body.address,
      }).select('id').single()
      if (error) throw error
      clientId = newClient.id
    }

    // 3. Crear animal
    const { data: animal, error: animalError } = await supabase.from('animals').insert({
      client_id: clientId, name: body.animal_name, species: body.animal_species,
      breed: body.animal_breed, sex: body.animal_sex,
    }).select('id').single()
    if (animalError) throw animalError

    // 4. Crear lead
    const { data: lead, error: leadError } = await supabase.from('leads').insert({
      client_id: clientId, animal_id: animal.id, status: 'waiting',
      service_type: body.service_type, description: body.description,
      priority: body.priority || 'normal', source: 'web_form',
    }).select('id').single()
    if (leadError) throw leadError

    // 5. Audit log
    await supabase.from('audit_log').insert({
      entity: 'lead', entity_id: lead.id, action: 'create',
      payload: { source: 'web_form', service_type: body.service_type }
    })

    // 6. TODO: Notificación Telegram (implementar con TELEGRAM_BOT_TOKEN)
    // 7. TODO: Email confirmación via send-email

    return new Response(
      JSON.stringify({ success: true, lead_id: lead.id, message: 'Lead creado exitosamente' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('create-lead error:', error)
    return new Response(JSON.stringify({ error: 'Error interno' }), { status: 500, headers: corsHeaders })
  }
})
EOF

# Stubs para otras edge functions
for fn in close-visit telegram-webhook whatsapp-preview send-email; do
cat > supabase/functions/$fn/index.ts << FNEOF
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

// TODO: Implementar Edge Function ${fn}
serve(async (req) => {
  return new Response(JSON.stringify({ message: '${fn} — por implementar' }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
FNEOF
done

cat > bot/README.md << 'EOF'
# Bot de Telegram — VetDesk

## Setup

1. Crear bot con @BotFather → obtener `BOT_TOKEN`
2. Registrar el `telegram_id` del técnico en `users.telegram_id`
3. Configurar webhook:

```bash
curl -X POST "https://api.telegram.org/bot{TOKEN}/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://{PROJECT}.supabase.co/functions/v1/telegram-webhook",
    "secret_token": "{TELEGRAM_WEBHOOK_SECRET}"
  }'
```

## Variables de entorno requeridas

- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_WEBHOOK_SECRET`
- `TELEGRAM_ADMIN_CHAT_ID`

## Comandos disponibles

- `/start` — Mensaje de bienvenida
- Botones inline en cada nuevo lead
EOF

log "Supabase migrations y Edge Functions generados"

# =============================================================================
# 19. index.html
# =============================================================================
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="VetDesk — Sistema operativo para clínica veterinaria móvil" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <title>VetDesk</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/main.js"></script>
  </body>
</html>
EOF

# =============================================================================
# 20. Git init
# =============================================================================
git init -q
git add .
git commit -m "chore: scaffold inicial VetDesk — arquitectura base completa" -q
log "Git inicializado con commit inicial"

# =============================================================================
# RESUMEN FINAL
# =============================================================================
echo ""
echo "  ✅  Scaffold completado con éxito"
echo "  ======================================"
echo ""
echo "  📁 Estructura generada:"
echo "     src/router, stores, layouts, views, components, composables, services, utils"
echo "     supabase/migrations (001-004), supabase/functions (5 edge functions)"
echo ""
echo "  📋 Próximos pasos:"
echo ""
echo "  1. Agrega tus credenciales en .env.local"
echo "     nano .env.local"
echo ""
echo "  2. Instala dependencias si no lo hiciste:"
echo "     npm install"
echo ""
echo "  3. Corre el dev server:"
echo "     npm run dev"
echo ""
echo "  4. Cuando tengas Supabase listo:"
echo "     npx supabase init"
echo "     npx supabase link --project-ref {PROJECT_REF}"
echo "     npx supabase db push"
echo ""
echo "  5. Deploy de Edge Functions:"
echo "     npx supabase functions deploy create-lead"
echo ""
echo "  🐾 ¡Listo para construir VetDesk!"
echo ""
