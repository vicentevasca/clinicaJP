import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const MiMascotaView = () => import('@/views/public/MiMascotaView.vue')

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

const PUBLIC_PATHS = ['/', '/solicitar', '/confirmacion', '/login', '/mi-mascota']

const router = createRouter({
  history: createWebHistory(),
  routes: [
    // Public
    { path: '/',             component: LandingView,      meta: { layout: 'public' } },
    { path: '/mi-mascota',  component: MiMascotaView,    meta: { layout: 'public' } },
    { path: '/solicitar',    component: SolicitudView,    meta: { layout: 'public' } },
    { path: '/confirmacion', component: ConfirmacionView, meta: { layout: 'public' } },
    { path: '/login',        component: LoginView,        meta: { layout: 'none' } },

    // App (protected — admin y tecnico)
    { path: '/app',          redirect: '/app/dashboard' },
    { path: '/app/dashboard',          component: DashboardView,      meta: { requiresAuth: true, roles: ['admin', 'tecnico'] } },
    { path: '/app/leads',              component: LeadsView,          meta: { requiresAuth: true, roles: ['admin', 'tecnico'] } },
    { path: '/app/leads/:id',          component: LeadDetailView,     meta: { requiresAuth: true, roles: ['admin', 'tecnico'] } },
    { path: '/app/agenda',             component: AgendaView,         meta: { requiresAuth: true, roles: ['admin', 'tecnico'] } },
    { path: '/app/visitas/:id',        component: VisitaDetailView,   meta: { requiresAuth: true, roles: ['admin', 'tecnico'] } },
    { path: '/app/pacientes',          component: PacientesView,      meta: { requiresAuth: true, roles: ['admin', 'tecnico'] } },
    { path: '/app/pacientes/:id',      component: PacienteDetailView, meta: { requiresAuth: true, roles: ['admin', 'tecnico'] } },
    { path: '/app/inventario',         component: InventarioView,     meta: { requiresAuth: true, roles: ['admin', 'tecnico'] } },
    { path: '/app/procedimientos',     component: ProcedimientosView, meta: { requiresAuth: true, roles: ['admin', 'tecnico'] } },
    { path: '/app/reportes',           component: ReportesView,       meta: { requiresAuth: true, roles: ['admin', 'tecnico'] } },
    { path: '/app/configuracion',      component: ConfiguracionView,  meta: { requiresAuth: true, roles: ['admin', 'tecnico'] } },

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

  // Restricción por rol
  if (to.meta.roles && to.meta.roles.length > 0) {
    const userRole = authStore.profile?.role
    if (!to.meta.roles.includes(userRole)) {
      // Evitar loop: si ya está en login o la ruta no requiere auth, no redirigir
      return authStore.isLoggedIn ? '/app/dashboard' : '/login'
    }
  }
})

export default router
