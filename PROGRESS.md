# VetDesk — Progreso del Proyecto

> Última actualización: 2026-04-18
> Estado: **Bugs resueltos** — análisis real del código + 10 bugs corregidos en esta sesión

---

## Índice

1. [Estado General](#1-estado-general)
2. [Bugs Críticos Nuevos — Detectados en revisión 2026-04-18](#2-bugs-críticos-nuevos--detectados-en-revisión-2026-04-18)
3. [Bugs del PROGRESS anterior — estado real](#3-bugs-del-progress-anterior--estado-real)
4. [Features Completados vs CLAUDE.md](#4-features-completados-vs-clamd)
5. [Gaps de Seguridad](#5-gaps-de-seguridad)
6. [Pendientes de Fase 3](#6-pendientes-de-fase-3)
7. [QA Checklist por Etapa](#7-qa-checklist-por-etapa)
8. [Variables de Entorno — Inconsistencias](#8-variables-de-entorno--inconsistencias)

---

## 1. Estado General

| Módulo | Estado | Observación |
|---|---|---|
| Auth (login, sesión) | ✅ Funcional | Guards con bug de rol asistente (ver NC-05) |
| App.vue layout routing | ✅ Corregido | NC-01 — imports directos, sin ref(null) |
| AppLayout sidebar | ✅ Corregido | NC-02/03/04 — storeToRefs directos, isActive funcional, responsive móvil |
| Formulario público (`/solicitar`) | ✅ Completo | |
| Pipeline leads (kanban + filtros) | ✅ Corregido | NC-06 — query param ?filter ya no rompe el kanban |
| Agenda / calendario visitas | ✅ Funcional | |
| Cierre de visita + ficha clínica | ✅ Corregido | NC-07 — animalId prop agregado a FichaForm |
| Inventario CRUD + alertas | ✅ Funcional | |
| Procedimientos CRUD | ✅ Funcional | |
| Edge Functions (5 core) | ✅ Completo | |
| Notificaciones toast | ✅ Funcional | |
| BaseModal | ✅ Funcional | |
| RLS policies | ✅ Completas | |
| visitsService.update() | ✅ Corregido | NC-09 — método update() implementado |
| Reportes — período | ✅ Corregido | NC-08 — watch re-fetchea visitas al cambiar período |
| Sidebar móvil | ✅ Corregido | NC-10 — drawer con overlay implementado |

---

## 2. Bugs Críticos Nuevos — Detectados en revisión 2026-04-18

Estos bugs NO estaban en el PROGRESS anterior y fueron detectados revisando el código fuente real.

### 🛑 NC-01 — App.vue: null reference crash en primer render (CRÍTICO)

**Archivo:** `src/App.vue` líneas 8, 24-29

**Problema:**
```js
// App.vue
const route = ref(null)  // null inicial

onMounted(async () => {
  route.value = useRoute()  // se asigna DESPUÉS del primer render
})
```

Template:
```vue
<AppLayout v-if="route.meta.requiresAuth">     <!-- null.meta → TypeError -->
<PublicLayout v-else-if="route.meta.layout === 'public'">
```

Antes de `onMounted`, `route.value` es `null`. El template accede a `route.meta.requiresAuth` → `null.meta` → TypeError. La app no renderiza correctamente en el primer ciclo.

**Fix requerido:**
```js
// Eliminar el ref(null) y el dynamic import
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()  // disponible directamente en script setup
const authStore = useAuthStore()
onMounted(() => {
  authStore.init()
  initTheme()
})
```

---

### 🛑 NC-02 — AppLayout.vue: `isActive()` siempre retorna false (CRÍTICO)

**Archivo:** `src/layouts/AppLayout.vue` líneas 5, 41-43

**Problema:**
```js
const route = ref(null)

onMounted(async () => {
  route.value = useRoute()  // el route object se asigna como VALUE del ref
})

function isActive(path) {
  return route.path === path  // ← BUG: route es Ref<null>, no tiene .path
  // route.path === undefined siempre
}
```

`route` es un `Ref`. Dentro de `isActive()`, no hay auto-unwrap de refs (solo ocurre en templates). `route.path` es `undefined`. La comparación siempre falla.

**Consecuencia:** El resaltado de la ruta activa en el sidebar NUNCA funciona. Todos los enlaces del sidebar se ven igual (sin estado activo).

**Fix requerido:**
```js
// Mismo fix que NC-01: importar useRoute() directamente
import { useRoute } from 'vue-router'
const route = useRoute()
// isActive ya funciona porque route.path existe
```

---

### 🛑 NC-03 — AppLayout.vue: badges del sidebar rotos (CRÍTICO)

**Archivo:** `src/layouts/AppLayout.vue` líneas 26-27

**Problema:**
```js
hasAlerts.value   = storeToRefs(inventoryStore).hasAlerts    // ← un Ref se asigna como VALUE de otro Ref
totalWaiting.value = storeToRefs(leadsStore).totalWaiting   // ← ídem
```

`storeToRefs(store).hasAlerts` es un `Ref<boolean>`. Al asignarlo como `.value` de otro ref, en el template Vue auto-unwrap solo un nivel:
- `totalWaiting.value` → `Ref<number>` (otro ref) → `Ref > 0` → comparación inválida → badge nunca aparece
- `hasAlerts.value` → `Ref<boolean>` (otro ref) → truthy siempre (objeto) → dot de alerta siempre visible

**Consecuencia:** El contador de leads en espera (`totalWaiting`) nunca muestra. El punto de alerta de inventario (`hasAlerts`) siempre es visible aunque no haya alertas.

**Fix requerido:**
```js
// Mismo fix: imports directos en script setup
const { hasAlerts } = storeToRefs(inventoryStore)
const { totalWaiting } = storeToRefs(leadsStore)
// No usar ref() wrapper — usar storeToRefs directamente como refs reactivos
```

---

### ⚠️ NC-04 — AppLayout.vue: profile del sidebar no reactivo (MEDIO)

**Archivo:** `src/layouts/AppLayout.vue` línea 24

**Problema:**
```js
profile.value = authStore.profile  // snapshot del valor, no referencia reactiva
```

Si el perfil del usuario se actualiza (ej: en ConfiguracionView), el sidebar NO reflejará el cambio. El nombre/rol en el footer del sidebar quedan desactualizados.

**Fix requerido:**
```js
const { profile } = storeToRefs(authStore)
```

---

### 🛑 NC-05 — Router: loop infinito para rol `asistente` (CRÍTICO)

**Archivo:** `src/router/index.js` líneas 38-70

**Problema:**
```js
// TODAS las rutas app tienen roles: ['admin', 'tecnico']
{ path: '/app/dashboard', meta: { requiresAuth: true, roles: ['admin', 'tecnico'] } }

// Guard:
if (!to.meta.roles.includes(userRole)) {
  return '/app/dashboard'  // ← redirige a dashboard
}
// Pero dashboard TAMBIÉN requiere ['admin', 'tecnico']
// Un asistente → dashboard → redirige a dashboard → loop infinito
```

**Consecuencia:** Un usuario con rol `asistente` queda atrapado en un redirect loop que congela la navegación.

**Fix requerido:** Crear una ruta de fallback para roles sin permiso, o definir qué rutas puede ver `asistente`:
```js
if (!to.meta.roles.includes(userRole)) {
  return '/login'  // o una vista de "acceso denegado"
}
```

---

### 🛑 NC-06 — LeadsView.vue: BA-02 fix incorrecto — rompe el kanban (CRÍTICO)

**Archivo:** `src/views/app/LeadsView.vue` líneas 43-45

**Problema (el "fix" de BA-02 es incorrecto):**
```js
if (route.query.filter) {
  filterService.value = route.query.filter  // ← BUG: asigna 'waiting' al filtro de service_type
}
```

Cuando `QuickActions` navega a `/app/leads?filter=waiting`, el código asigna `filterService.value = 'waiting'`. Pero `filterService` filtra por `service_type` (valores como 'vacunacion', 'desparasitacion'...). Ningún lead tiene `service_type === 'waiting'`, por lo que **todas las columnas del kanban quedan vacías**.

La intención correcta era filtrar/resaltar por STATUS, no por service_type.

**Fix requerido:** Separar el query param `?filter` (para status) de `?service` (para service_type):
```js
// En LeadsView, quitar el bloque filterService = route.query.filter
// El ?filter=waiting es solo referencial — el kanban ya muestra por status column
// Si se quiere scroll/highlight, implementarlo por separado
if (route.query.service) {
  filterService.value = route.query.service
}
// Quitar el if (route.query.filter) mal implementado
```

---

### ⚠️ NC-07 — FichaForm.vue: animal_id undefined en nuevo registro clínico (MEDIO)

**Archivo:** `src/components/clinical/FichaForm.vue` línea 46

**Problema:**
```js
const payload = {
  visit_id:   props.visitId,
  animal_id:  props.existing?.animal_id,  // ← undefined cuando props.existing = null
  ...
}
```

Cuando no existe registro previo (`props.existing = null`), `animal_id` es `undefined`. La tabla `clinical_records` tiene `animal_id NOT NULL`. El INSERT falla con violación de constraint.

**Archivo relacionado:** `VisitaDetailView.vue` línea 138:
```vue
:existing="visit.clinical_records?.[0]"  <!-- null si es la primera vez -->
```

No pasa `animal_id` del visit al FichaForm por otra vía.

**Fix requerido:** Agregar prop `animalId` a FichaForm y usarlo en el payload:
```vue
<!-- VisitaDetailView -->
<FichaForm :visit-id="visit.id" :animal-id="visit.animal_id" :existing="visit.clinical_records?.[0]" />
```
```js
// FichaForm
const props = defineProps({
  visitId:  { type: String, required: true },
  animalId: { type: String, required: true },  // nuevo
  existing: { type: Object, default: null },
})
// En payload:
animal_id: props.animalId,
```

---

### ⚠️ NC-08 — ReportesView.vue: visitas no se re-fetchean al cambiar período (MEDIO)

**Archivo:** `src/views/app/ReportesView.vue` líneas 50-65

**Problema:**
```js
// onMounted (carga única):
visitsService.getByRange(from7d.toISOString(), now.toISOString())
// Solo carga 7 días de visitas

// Si cambias a período '30d':
// periodVisits computed filtra los visits ya cargados (solo 7d)
// Las visitas de hace 8-30 días no están en memoria → stats incorrectos
```

Los leads se cargan todos (`leadsService.getAll()` sin filtro) entonces su filtrado por período es correcto. Pero las visitas solo se cargan una vez con el rango inicial.

**Fix requerido:** Agregar un `watch` al `period` que re-fetchee visitas:
```js
watch(period, async (newPeriod) => {
  const from = periods[newPeriod]
  visits.value = await visitsService.getByRange(from.toISOString(), now.toISOString())
})
```

---

### ⚠️ NC-09 — visitsService: método `update()` faltante (MEDIO)

**Archivo:** `src/services/visits.service.js`

**Problema:** BM-11 en el PROGRESS anterior fue marcado como "✅ CORREGIDO — Agregado `update(id, payload)`", pero el archivo actual NO contiene el método `update()`. Solo tiene:
- `getByRange`
- `getById`
- `updateStatus`
- `getByLeadId`
- `create`

**Consecuencia:** Cualquier código que intente llamar `visitsService.update(id, payload)` fallará con `TypeError: visitsService.update is not a function`.

**Fix requerido:** Agregar el método:
```js
async update(id, payload) {
  const { data, error } = await supabase
    .from('visits').update({ ...payload, updated_at: new Date().toISOString() })
    .eq('id', id).select().single()
  if (error) throw error
  return data
},
```

---

### 💡 NC-10 — AppLayout.vue: sidebar no responsive en móvil (BAJO)

**Archivo:** `src/layouts/AppLayout.vue` líneas 9-10, 49

**Problema:**
```js
const sidebarOpen = ref(false)  // declarado pero NUNCA usado
```

El sidebar es `w-64 flex-shrink-0` fijo. En pantallas móviles, ocupa la mayor parte del ancho sin posibilidad de cerrarse. El técnico en campo usa el sistema principalmente desde móvil (requisito CLAUDE.md §16).

**Fix requerido:** Implementar sidebar como drawer en móvil usando `sidebarOpen`, con overlay y botón hamburger en el header.

---

## 3. Bugs del PROGRESS anterior — estado real

### ✅ Bugs Críticos (confirmados corregidos)

| # | Bug | Estado real |
|---|---|---|
| BC-01 | `useToast().addToast` type ignorado | ✅ Corregido — alias OK |
| BC-02 | `LeadFormModal` CREATE con FK undefined | ✅ Corregido — usa Edge Function |
| BC-03 | `FichaForm` sin `created_by` | ✅ Corregido — pero nuevo bug NC-07 con animal_id |

### ✅ Bugs Medios (confirmados corregidos)

| # | Bug | Estado real |
|---|---|---|
| BM-01 | Doble entry en `lead_status_history` | ✅ Corregido |
| BM-02 | `close-visit` sin validar estado previo | ✅ Corregido |
| BM-03 | Telegram webhook sin verificar chat_id | ✅ Corregido |
| BM-04 | RLS faltante en 4 tablas | ✅ Corregido |
| BM-07 | `leads_source_check` sin mi_mascota_portal | ✅ Corregido |
| BM-08 | Queries directas en LeadDetailView | ✅ Corregido — usa servicios |
| BM-09 | Query directa en ConfiguracionView | ✅ Corregido — usa usersService |
| BM-10 | Update directo en LeadFormModal | ✅ Corregido — usa leadsService |
| **BM-11** | **visitsService sin update()** | **❌ PENDIENTE — marcado corregido pero NO implementado** |

### ✅ Bugs UI/UX (estado real)

| # | Bug | Estado real |
|---|---|---|
| BA-01 | InventarioView no lee ?filter=critical | ✅ Corregido |
| **BA-02** | **LeadsView no lee ?filter=waiting** | **⚠️ Fix incorrecto → ver NC-06** |
| BA-03 | BaseModal Escape no funciona | ✅ Corregido |
| BA-04 | AgendaView race condition | ✅ Corregido |
| **BA-05** | **ReportesView período ignorado** | **⚠️ Parcialmente corregido → ver NC-08** |
| BA-06 | WhatsAppPreview null name | ✅ Corregido |
| BA-07 | ConfiguracionView botón "Eliminar cuenta" | ✅ Corregido — muestra mensaje informativo |
| BA-09 | Router sin guards por rol | ⚠️ Implementado pero con loop infinito → ver NC-05 |

---

## 4. Features Completados vs CLAUDE.md

### Fase 1 — Core MVP ✅

| Feature | Status |
|---|---|
| Setup Vite + Vue 3 + Tailwind + GSAP | ✅ |
| Supabase migrations + RLS | ✅ 5 migrations |
| Auth: login, sesión | ✅ |
| `create-lead` Edge Function | ✅ |
| Formulario `/solicitar` (4 pasos) | ✅ |
| Dashboard KPIs | ✅ |
| Pipeline leads kanban | ✅ (con bug NC-06) |
| Bot Telegram + botones inline | ✅ |
| `telegram-webhook` | ✅ |

### Fase 2 — Operación Completa

| Feature | Status | Notas |
|---|---|---|
| Agenda / calendario visitas | ✅ | |
| Detalle visita + cierre | ⚠️ | Bug NC-07 en FichaForm |
| `close-visit` Edge Function | ✅ | |
| Fichas clínicas creación | ⚠️ | Bug NC-07 (animal_id) |
| Historial clínico por animal | ✅ | |
| Inventario CRUD + alertas | ✅ | |
| CRUD procedimientos + linked inventory | ✅ | |
| WhatsApp preview | ✅ | |
| Email transaccional Resend | ✅ | |
| Perfil paciente | ✅ | |

### Fase 3 — Refinamiento

| Feature | Status |
|---|---|
| Reportes período | ⚠️ Parcial — NC-08 |
| Landing pública GSAP | ✅ |
| Rol asistente (vistas restringidas) | ⚠️ Bug NC-05 loop infinito |
| Upload fotos pacientes (Storage) | ❌ Pendiente |
| Upload manuales PDF | ❌ Pendiente |
| PWA básica | ✅ |
| Tests de flujos críticos | ❌ Pendiente |
| Sidebar responsive móvil | ❌ Pendiente (NC-10) |

### Extra Features (implementadas fuera de CLAUDE.md)

| Feature | Estado |
|---|---|
| Portal "Mi Mascota" `/mi-mascota` | ✅ |
| `get-availability` Edge Function | ✅ |
| `get-client-portal-data` Edge Function | ✅ |
| `create-consultation-request` Edge Function | ✅ |
| Migration 005 (`rut`, `working_hours`, slots) | ✅ |

---

## 5. Gaps de Seguridad

| # | Issue | Severidad | Estado |
|---|---|---|---|
| SG-01 | `send-email` con validación `X-Api-Secret` | Alta | ✅ Implementado |
| SG-02 | `telegram-webhook` verifica `chat_id` vs `users.telegram_id` | Alta | ✅ Corregido |
| SG-03 | `close-visit` valida estado previo del lead | Media | ✅ Corregido |
| SG-04 | `visit_procedures` RLS `WITH CHECK` vs `USING` | Media | ⚠️ Pendiente |
| SG-05 | Rate limiting en Edge Functions públicas | Baja | ⚠️ Pendiente |

---

## 6. Pendientes de Fase 3

1. **Upload de fotos** — Supabase Storage para `animals.photo_url`
2. **Upload de manuales PDF** — `inventory.manual_url`
3. **Sidebar responsive** — drawer móvil con hamburger (NC-10)
4. **Tests E2E** — flujos críticos: creación lead, cierre visita, Mi Mascota
5. **Optimización** — índices adicionales en PostgreSQL
6. **Fixes bloqueantes** — NC-01 a NC-09 deben resolverse antes de producción

---

## 7. QA Checklist por Etapa

### Login y Auth
- [ ] Login con credenciales válidas → redirige a `/app/dashboard`
- [ ] Login con credenciales inválidas → toast de error sin crash
- [ ] Sin sesión → redirige a `/login` desde cualquier ruta `/app/*`
- [ ] Logout → limpia sesión y redirige a `/login`

### Primer render y layout
- [ ] App.vue renderiza sin TypeError en primer ciclo (NC-01)
- [ ] Sidebar muestra ruta activa correctamente (NC-02)
- [ ] Badge leads en espera muestra número correcto (NC-03)
- [ ] Dot de alerta inventario solo aparece con stock crítico (NC-03)
- [ ] Sidebar refleja cambios de perfil (NC-04)

### Formulario Público `/solicitar`
- [ ] Paso 1 valida teléfono chileno (+56...)
- [ ] Paso 2 valida especie requerida
- [ ] Paso 3 valida descripción mínimo 20 chars
- [ ] Submit completo → redirect a `/confirmacion`
- [ ] Lead aparece en Telegram del técnico en <10s

### Pipeline Leads `/app/leads`
- [ ] Kanban muestra 4 columnas con leads correctos
- [ ] Filtro por servicio filtra correctamente
- [ ] Link desde QuickActions/Dashboard NO vacía el kanban (NC-06)
- [ ] Búsqueda por texto filtra por nombre cliente/animal
- [ ] Nuevo lead desde modal → aparece en "En espera"
- [ ] Cambio de estado → toast de confirmación

### Agenda `/app/agenda`
- [ ] Calendario mes actual renderiza visitas
- [ ] Visitas pasadas/futuras se muestran en lista
- [ ] Click en visita → `VisitaDetailView`
- [ ] Nueva visita desde modal → aparece en calendario

### Cierre de Visita `/app/visitas/:id`
- [ ] Botón "Cerrar visita" aparece cuando status = in_progress
- [ ] Al guardar ficha → `clinical_records` creado correctamente (NC-07)
- [ ] Formulario incluye animal_id válido (NC-07)
- [ ] Toast de confirmación al cerrar

### Inventario `/app/inventario`
- [ ] Lista todos los insumos con stock y color coding
- [ ] Insumo bajo stock → aparece banner de alerta
- [ ] CRUD completo: crear, editar, eliminar
- [ ] Link `?filter=critical` muestra solo críticos

### Reportes `/app/reportes`
- [ ] Cambiar período actualiza métricas de leads
- [ ] Cambiar período re-fetchea visitas (NC-08)
- [ ] Tasa de conversión calculada correctamente

### Mi Mascota `/mi-mascota`
- [ ] Búsqueda por RUT válida → muestra cliente + animales
- [ ] Búsqueda por teléfono → muestra cliente + animales
- [ ] RUT inválido → mensaje de error sin crash
- [ ] Submit consulta → aparece en Telegram del técnico

---

## 8. Variables de Entorno — Inconsistencias

| Variable | Frontend | Edge Function | Status |
|---|---|---|---|
| URL Supabase | `VITE_SUPABASE_URL` | `SUPABASE_URL` | ✅ OK |
| Anon Key | `VITE_SUPABASE_ANON_KEY` | N/A | ✅ OK |
| Service Role | N/A | `SUPABASE_SERVICE_ROLE_KEY` | ✅ OK |
| Portal Secret | `VITE_PORTAL_API_SECRET` | `VETDESK_PORTAL_SECRET` | ⚠️ Nombres diferentes |
| Telegram Bot | N/A | `TELEGRAM_BOT_TOKEN` | ✅ OK |
| Telegram Chat ID | N/A | `TELEGRAM_ADMIN_CHAT_ID` | ✅ OK |
| Email API | N/A | `RESEND_API_KEY` | ✅ OK |

**Acción requerida:** Verificar en Supabase Dashboard → Settings → Secrets que el secret del portal se llama `VETDESK_PORTAL_SECRET`.

---

## Resumen de bugs — estado final 2026-04-18

### ✅ Todos los bugs NC resueltos en esta sesión

| # | Bug | Archivos modificados |
|---|---|---|
| NC-01 | App.vue null reference crash | `src/App.vue` |
| NC-02 | AppLayout isActive() roto | `src/layouts/AppLayout.vue` |
| NC-03 | AppLayout badges rotos | `src/layouts/AppLayout.vue` |
| NC-04 | AppLayout profile no reactivo | `src/layouts/AppLayout.vue` |
| NC-05 | Router loop infinito asistente | `src/router/index.js` |
| NC-06 | LeadsView BA-02 fix incorrecto | `src/views/app/LeadsView.vue` |
| NC-07 | FichaForm animal_id undefined | `src/components/clinical/FichaForm.vue`, `src/views/app/VisitaDetailView.vue` |
| NC-08 | ReportesView visitas no re-fetchean | `src/views/app/ReportesView.vue` |
| NC-09 | visitsService.update() faltante | `src/services/visits.service.js` |
| NC-10 | Sidebar no responsive móvil | `src/layouts/AppLayout.vue` |

### ⚠️ Pendientes (baja prioridad — no bloquean MVP)
- **SG-04** — RLS `visit_procedures` usar `WITH CHECK` en lugar de `USING` para INSERT policies
- **SG-05** — Rate limiting en Edge Functions públicas (Supabase tiene límites implícitos)
- **Tests E2E** — flujos críticos: creación lead, cierre visita, Mi Mascota
- **Upload fotos/PDFs** — Supabase Storage para animals.photo_url e inventory.manual_url
