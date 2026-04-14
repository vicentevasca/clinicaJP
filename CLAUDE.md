# CLAUDE.md — VetDesk
## Sistema Operativo para Clínica Veterinaria Móvil

> Documento rector para Claude Code. Toda decisión de desarrollo debe respetar esta base.
> Versión: 1.0 | Vi_Studio | Abril 2026

---

## 1. CONTEXTO Y OBJETIVO DEL PROYECTO

### ¿Qué es VetDesk?

VetDesk es la columna vertebral operativa de una clínica veterinaria móvil/ambulatoria independiente. No es un SaaS genérico ni un sistema de clínica tradicional. Es una herramienta diseñada para un técnico veterinario que opera en campo, gestionando simultáneamente su rol de vendedor, agendador, clínico y administrativo.

### Problema que resuelve

El técnico pierde tiempo crítico en fricción operativa:
- Recibe leads por WhatsApp/teléfono y los pierde o no les hace seguimiento
- No sabe si tiene el insumo antes de confirmar una visita
- No tiene trazabilidad clínica del paciente entre visitas
- Responde tarde a solicitudes nuevas, perdiendo clientes potenciales

### Objetivo del sistema

Reducir el tiempo de respuesta a leads a menos de 2 minutos. Centralizar la operación completa (captación → agenda → ejecución → cierre clínico) en una sola plataforma. Construir un MVP tan robusto como el producto final.

### Foco del negocio

- Servicios ambulatorios de baja/media complejidad: vacunación, desparasitación, chequeos, recetas, atención a domicilio
- Servicios complementarios: corte de pelo, recomendación de insumos/alimentación
- Pacientes: perros, gatos, aves, gallinas, caballos, bovinos y otros definidos por el técnico
- Sin procedimientos quirúrgicos en el alcance actual

---

## 2. STACK TECNOLÓGICO

### Decisiones de arquitectura — NO modificar sin justificación documentada

| Capa | Tecnología | Versión | Justificación |
|---|---|---|---|
| Frontend | Vue 3 + Vite | Vue 3.x / Vite 5.x | Composition API, rendimiento, ecosistema |
| Estilos | Tailwind CSS | v3.x | Utility-first, consistencia, velocidad |
| Animaciones | GSAP | 3.x | Animaciones de UI fluidas y profesionales |
| Backend / DB | Supabase | Cloud | PostgreSQL relacional con RLS nativo |
| Auth | Supabase Auth | — | JWT nativos, integración directa con RLS |
| Storage | Supabase Storage | — | PDFs de manuales, fotos de pacientes |
| Deploy Frontend | Vercel | — | CI/CD automático desde Git, edge network |
| Email | Resend | — | Simple, gratuito en MVP, API limpia |
| Bot | Telegram Bot API | — | Notificación instantánea + acciones inline |
| Routing | Vue Router 4 | — | SPA con guards de autenticación |
| Estado global | Pinia | — | Store reactivo para Vue 3 |
| HTTP Client | @supabase/supabase-js | — | Cliente oficial, no usar fetch raw |

### Por qué Supabase sobre Firebase

- Modelo relacional (PostgreSQL) es superior para este dominio: relaciones claras entre leads, animales, clientes, visitas, insumos y fichas
- RLS (Row Level Security) más expresivo y seguro que reglas Firestore
- Edge Functions en Deno — compatibles 1:1 con entornos Node en VPS futuro
- Sin vendor lock-in en lógica de negocio

### Compatibilidad futura con VPS

- Las Edge Functions de Supabase se escriben como handlers HTTP estándar
- El cliente supabase-js funciona igual apuntando a una instancia self-hosted
- Variables de entorno como única diferencia entre entornos
- **No usar** ninguna feature exclusiva de Firebase, Cloudflare Workers o servicios con lock-in

---

## 3. ESTRUCTURA DE CARPETAS

```
vetdesk/
├── CLAUDE.md                          # Este documento
├── .env.local                         # Variables locales (no commitear)
├── .env.example                       # Template de variables (sí commitear)
├── package.json
├── vite.config.js
├── tailwind.config.js
├── index.html
│
├── src/
│   ├── main.js                        # Entry point
│   ├── App.vue                        # Root component
│   │
│   ├── router/
│   │   └── index.js                   # Rutas + guards de auth
│   │
│   ├── stores/                        # Pinia stores
│   │   ├── auth.js                    # Usuario autenticado, rol, sesión
│   │   ├── leads.js                   # Estado de leads y pipeline
│   │   ├── agenda.js                  # Visitas y calendario
│   │   ├── inventory.js               # Insumos y alertas de stock
│   │   ├── patients.js                # Animales y propietarios
│   │   └── notifications.js           # Alertas internas del sistema
│   │
│   ├── layouts/
│   │   ├── PublicLayout.vue           # Landing y formulario público
│   │   └── AppLayout.vue             # Panel interno con sidebar
│   │
│   ├── views/
│   │   ├── public/
│   │   │   ├── LandingView.vue        # Página principal pública
│   │   │   ├── SolicitudView.vue      # Formulario multi-paso de lead
│   │   │   └── ConfirmacionView.vue   # Post-formulario
│   │   │
│   │   ├── auth/
│   │   │   └── LoginView.vue          # Login de admin/técnico
│   │   │
│   │   └── app/
│   │       ├── DashboardView.vue      # Métricas, alertas, accesos rápidos
│   │       ├── LeadsView.vue          # Pipeline completo
│   │       ├── LeadDetailView.vue     # Detalle de lead + acciones
│   │       ├── AgendaView.vue         # Calendario de visitas
│   │       ├── VisitaDetailView.vue   # Detalle de visita + cierre
│   │       ├── PacientesView.vue      # Listado de animales/propietarios
│   │       ├── PacienteDetailView.vue # Ficha clínica + historial
│   │       ├── InventarioView.vue     # CRUD insumos + alertas de stock
│   │       ├── ProcedimientosView.vue # Catálogo de procedimientos
│   │       ├── ReportesView.vue       # Métricas y resúmenes
│   │       └── ConfiguracionView.vue  # Parámetros del sistema
│   │
│   ├── components/
│   │   ├── ui/                        # Componentes base reutilizables
│   │   │   ├── BaseButton.vue
│   │   │   ├── BaseInput.vue
│   │   │   ├── BaseSelect.vue
│   │   │   ├── BaseModal.vue
│   │   │   ├── BaseBadge.vue
│   │   │   ├── BaseCard.vue
│   │   │   ├── BaseAlert.vue
│   │   │   └── BaseToast.vue
│   │   │
│   │   ├── leads/
│   │   │   ├── LeadKanban.vue         # Vista pipeline en columnas
│   │   │   ├── LeadCard.vue           # Card de lead en kanban
│   │   │   ├── LeadStatusBadge.vue    # Badge de estado con colores
│   │   │   ├── LeadTimeline.vue       # Historial de cambios del lead
│   │   │   └── WhatsAppPreview.vue    # Texto pre-armado + botón copiar
│   │   │
│   │   ├── agenda/
│   │   │   ├── CalendarView.vue       # Vista mensual/semanal/día
│   │   │   ├── VisitaCard.vue         # Card de visita en calendario
│   │   │   └── VisitaForm.vue         # Formulario crear/editar visita
│   │   │
│   │   ├── inventory/
│   │   │   ├── InsumoCard.vue         # Card de insumo con stock visual
│   │   │   ├── StockAlertBanner.vue   # Banner de alertas críticas
│   │   │   └── InsumoForm.vue         # Formulario CRUD insumo
│   │   │
│   │   ├── clinical/
│   │   │   ├── FichaClinica.vue       # Visualización de ficha completa
│   │   │   ├── FichaForm.vue          # Formulario cierre de visita
│   │   │   └── HistorialAnimal.vue    # Timeline clínico del animal
│   │   │
│   │   └── dashboard/
│   │       ├── MetricCard.vue         # Tarjeta de métrica KPI
│   │       ├── AlertsPanel.vue        # Panel de alertas activas
│   │       └── QuickActions.vue       # Accesos rápidos
│   │
│   ├── composables/                   # Lógica reutilizable (Vue 3)
│   │   ├── useAuth.js                 # Sesión y permisos
│   │   ├── useLeads.js                # Operaciones sobre leads
│   │   ├── useInventory.js            # Lógica de stock y alertas
│   │   ├── useWhatsApp.js             # Generación de texto y deep link
│   │   ├── useToast.js                # Sistema de notificaciones UI
│   │   └── useGsap.js                 # Animaciones globales GSAP
│   │
│   ├── services/                      # Capa de acceso a datos
│   │   ├── supabase.js                # Cliente Supabase inicializado
│   │   ├── leads.service.js           # CRUD y operaciones de leads
│   │   ├── visits.service.js          # CRUD visitas
│   │   ├── inventory.service.js       # CRUD inventario
│   │   ├── patients.service.js        # CRUD animales y propietarios
│   │   ├── clinical.service.js        # Fichas clínicas
│   │   └── notifications.service.js   # Email via Resend
│   │
│   ├── utils/
│   │   ├── formatters.js              # Fechas, moneda, texto
│   │   ├── validators.js              # Validaciones de formularios
│   │   ├── whatsapp.js                # Construcción de mensajes y deep links
│   │   └── constants.js              # Enums, estados, categorías
│   │
│   └── assets/
│       ├── styles/
│       │   ├── main.css               # Tailwind imports + variables CSS
│       │   └── animations.css         # Clases GSAP reutilizables
│       └── icons/                     # SVGs propios del sistema
│
├── supabase/
│   ├── migrations/                    # SQL migrations en orden
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_rls_policies.sql
│   │   ├── 003_functions.sql
│   │   └── 004_triggers.sql
│   │
│   └── functions/                     # Edge Functions (Deno)
│       ├── create-lead/
│       │   └── index.ts               # POST /functions/v1/create-lead
│       ├── close-visit/
│       │   └── index.ts               # POST /functions/v1/close-visit
│       ├── telegram-webhook/
│       │   └── index.ts               # POST /functions/v1/telegram-webhook
│       ├── whatsapp-preview/
│       │   └── index.ts               # POST /functions/v1/whatsapp-preview
│       └── send-email/
│           └── index.ts               # POST /functions/v1/send-email
│
└── bot/
    └── README.md                      # Instrucciones de setup del bot Telegram
```

---

## 4. MODELO DE DATOS — PostgreSQL (Supabase)

### Principios del modelo

- Normalización relacional estricta — no duplicar datos en columnas
- Toda tabla tiene `id UUID DEFAULT gen_random_uuid()`, `created_at`, `updated_at`
- Soft delete donde aplique (`deleted_at TIMESTAMP`)
- Audit log centralizado para acciones críticas
- RLS activo en todas las tablas — nunca desactivar

---

### 4.1 Tabla: `users`

```sql
CREATE TABLE users (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  email       TEXT NOT NULL UNIQUE,
  role        TEXT NOT NULL CHECK (role IN ('admin', 'tecnico', 'asistente')),
  phone       TEXT,                        -- Para deep links WhatsApp del técnico
  telegram_id BIGINT UNIQUE,               -- ID de Telegram para el bot
  active      BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.2 Tabla: `clients`

```sql
CREATE TABLE clients (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT NOT NULL,
  phone      TEXT NOT NULL,               -- Número con código país (+56...)
  email      TEXT,
  region     TEXT,
  comuna     TEXT,
  address    TEXT,
  notes      TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.3 Tabla: `animals`

```sql
CREATE TABLE animals (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id   UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  species     TEXT NOT NULL CHECK (species IN (
                'perro','gato','ave','gallina','caballo','bovino','otro'
              )),
  breed       TEXT,
  birth_date  DATE,
  sex         TEXT CHECK (sex IN ('macho','hembra','desconocido')),
  weight_kg   NUMERIC(5,2),
  photo_url   TEXT,                       -- Supabase Storage URL
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.4 Tabla: `leads`

```sql
CREATE TABLE leads (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id         UUID REFERENCES clients(id),
  animal_id         UUID REFERENCES animals(id),
  assigned_to       UUID REFERENCES users(id),          -- Técnico responsable
  status            TEXT NOT NULL DEFAULT 'waiting'
                      CHECK (status IN ('waiting','in_progress','done','cancelled')),
  service_type      TEXT NOT NULL,                      -- Tipo de servicio solicitado
  description       TEXT,                               -- Descripción del caso
  priority          TEXT DEFAULT 'normal'
                      CHECK (priority IN ('low','normal','high','urgent')),
  confidence_score  INTEGER DEFAULT 50 CHECK (confidence_score BETWEEN 0 AND 100),
  source            TEXT DEFAULT 'web_form'
                      CHECK (source IN ('web_form','telegram','whatsapp','phone','referral')),
  inventory_checked BOOLEAN DEFAULT FALSE,             -- Si se validaron insumos
  inventory_ok      BOOLEAN,                           -- Resultado de la validación
  telegram_message_id BIGINT,                          -- ID del mensaje en Telegram
  notes             TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);
```

**Estados del lead:**
- `waiting` — Recién recibido, sin acción del técnico
- `in_progress` — Técnico contactó o está gestionando
- `done` — Visita ejecutada y cerrada
- `cancelled` — Cancelado por cliente o técnico

### 4.5 Tabla: `lead_status_history`

```sql
CREATE TABLE lead_status_history (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id     UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  from_status TEXT,
  to_status   TEXT NOT NULL,
  changed_by  UUID REFERENCES users(id),
  note        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.6 Tabla: `visits`

```sql
CREATE TABLE visits (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id         UUID NOT NULL REFERENCES leads(id),
  animal_id       UUID NOT NULL REFERENCES animals(id),
  client_id       UUID NOT NULL REFERENCES clients(id),
  assigned_to     UUID NOT NULL REFERENCES users(id),
  scheduled_at    TIMESTAMPTZ NOT NULL,
  duration_min    INTEGER DEFAULT 60,
  status          TEXT NOT NULL DEFAULT 'scheduled'
                    CHECK (status IN ('scheduled','confirmed','in_progress','completed','cancelled')),
  address         TEXT NOT NULL,
  notes           TEXT,
  completed_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.7 Tabla: `procedures`

```sql
CREATE TABLE procedures (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  description TEXT,
  category    TEXT NOT NULL CHECK (category IN (
                'vacunacion','desparasitacion','chequeo','receta',
                'corte_pelo','atencion_domicilio','otro'
              )),
  duration_min INTEGER DEFAULT 30,
  base_price  NUMERIC(10,2),
  active      BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.8 Tabla: `inventory`

```sql
CREATE TABLE inventory (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL,
  description  TEXT,
  category     TEXT NOT NULL CHECK (category IN ('vacuna','farmaco','insumo','herramienta')),
  stock        NUMERIC(10,2) NOT NULL DEFAULT 0,
  min_stock    NUMERIC(10,2) NOT NULL DEFAULT 0,    -- Umbral de alerta
  unit         TEXT NOT NULL DEFAULT 'unidad',      -- unidad, ml, mg, caja, etc.
  cost_per_unit NUMERIC(10,2),
  manual_url   TEXT,                                -- Supabase Storage — PDF proveedor
  supplier_name TEXT,
  supplier_phone TEXT,
  supplier_email TEXT,
  active       BOOLEAN DEFAULT TRUE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.9 Tabla: `procedure_inventory` (N:M)

```sql
CREATE TABLE procedure_inventory (
  procedure_id  UUID NOT NULL REFERENCES procedures(id) ON DELETE CASCADE,
  inventory_id  UUID NOT NULL REFERENCES inventory(id) ON DELETE CASCADE,
  quantity      NUMERIC(10,3) NOT NULL DEFAULT 1,   -- Cantidad requerida por ejecución
  notes         TEXT,
  PRIMARY KEY (procedure_id, inventory_id)
);
```

### 4.10 Tabla: `visit_procedures`

```sql
CREATE TABLE visit_procedures (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  visit_id     UUID NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
  procedure_id UUID NOT NULL REFERENCES procedures(id),
  executed     BOOLEAN DEFAULT FALSE,
  notes        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.11 Tabla: `inventory_usage`

```sql
CREATE TABLE inventory_usage (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  visit_id      UUID NOT NULL REFERENCES visits(id),
  inventory_id  UUID NOT NULL REFERENCES inventory(id),
  quantity_used NUMERIC(10,3) NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.12 Tabla: `clinical_records`

```sql
CREATE TABLE clinical_records (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  visit_id        UUID NOT NULL UNIQUE REFERENCES visits(id),
  animal_id       UUID NOT NULL REFERENCES animals(id),
  lead_id         UUID REFERENCES leads(id),
  weight_kg       NUMERIC(5,2),
  temperature_c   NUMERIC(4,1),
  diagnosis       TEXT,
  treatment       TEXT,
  prescriptions   TEXT,
  observations    TEXT,
  next_visit_rec  TEXT,                               -- Recomendación próxima visita
  created_by      UUID REFERENCES users(id),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.13 Tabla: `audit_log`

```sql
CREATE TABLE audit_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id),
  entity      TEXT NOT NULL,                          -- 'lead', 'visit', 'inventory', etc.
  entity_id   UUID NOT NULL,
  action      TEXT NOT NULL,                          -- 'create', 'update', 'delete', 'close'
  payload     JSONB,                                  -- Snapshot del cambio
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 5. RLS — ROW LEVEL SECURITY

### Principios

- RLS habilitado en **todas** las tablas sin excepción
- El cliente Supabase en frontend **nunca** tiene acceso sin auth
- Las Edge Functions usan `service_role` key — solo internamente, nunca en frontend
- El rol `asistente` solo ve registros donde `assigned_to = auth.uid()`

### Políticas clave

```sql
-- Leads: admin ve todo, asistente solo los suyos
CREATE POLICY "leads_select" ON leads FOR SELECT
  USING (
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    OR assigned_to = auth.uid()
  );

-- Inventory: todos los roles con auth pueden leer
CREATE POLICY "inventory_read" ON inventory FOR SELECT
  USING (auth.role() = 'authenticated');

-- Inventory: solo admin puede modificar
CREATE POLICY "inventory_write" ON inventory FOR ALL
  USING ((SELECT role FROM users WHERE id = auth.uid()) = 'admin');

-- Clinical records: admin total, asistente solo lee de sus visitas
CREATE POLICY "clinical_read" ON clinical_records FOR SELECT
  USING (
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    OR EXISTS (
      SELECT 1 FROM visits v
      WHERE v.id = clinical_records.visit_id
      AND v.assigned_to = auth.uid()
    )
  );

-- Audit log: solo admin puede leer, nadie puede modificar desde frontend
CREATE POLICY "audit_read" ON audit_log FOR SELECT
  USING ((SELECT role FROM users WHERE id = auth.uid()) = 'admin');
```

---

## 6. EDGE FUNCTIONS (Supabase / Deno)

Todas las funciones usan `service_role` internamente y validan el token JWT del usuario o un secret compartido según el caso.

---

### 6.1 `create-lead` — POST /functions/v1/create-lead

**Propósito:** Recibir el formulario público, crear o recuperar el cliente, crear el animal si es nuevo, crear el lead en estado `waiting`, disparar notificación Telegram al técnico y email interno.

**Input:**
```typescript
{
  // Cliente
  client_name: string
  client_phone: string          // Formato +56XXXXXXXXX
  client_email?: string
  region: string
  comuna: string
  address: string

  // Animal
  animal_name: string
  animal_species: string
  animal_breed?: string
  animal_age_years?: number
  animal_sex?: string

  // Solicitud
  service_type: string
  description: string
  priority?: 'low' | 'normal' | 'high' | 'urgent'
}
```

**Output:**
```typescript
{
  success: boolean
  lead_id: string
  message: string
}
```

**Lógica interna:**
1. Validar campos requeridos
2. Buscar cliente existente por `phone` — si existe, reusar; si no, crear
3. Crear animal asociado al cliente
4. Crear lead con `status: 'waiting'`, `source: 'web_form'`
5. Llamar internamente a `send-telegram-notification`
6. Llamar internamente a `send-email` (confirmación al cliente si tiene email)
7. Registrar en `audit_log`
8. Retornar `lead_id`

---

### 6.2 `close-visit` — POST /functions/v1/close-visit

**Propósito:** Cerrar una visita ejecutada. Crea la ficha clínica, descuenta el inventario, actualiza el lead a `done`, registra en audit log.

**Auth:** JWT del técnico/admin requerido.

**Input:**
```typescript
{
  visit_id: string
  clinical: {
    weight_kg?: number
    temperature_c?: number
    diagnosis: string
    treatment: string
    prescriptions?: string
    observations?: string
    next_visit_rec?: string
  }
  procedures_executed: string[]           // IDs de visit_procedures
  inventory_used: Array<{
    inventory_id: string
    quantity_used: number
  }>
}
```

**Output:**
```typescript
{
  success: boolean
  clinical_record_id: string
  stock_alerts: Array<{                   // Insumos que quedaron bajo min_stock
    inventory_id: string
    name: string
    stock: number
    min_stock: number
  }>
}
```

**Lógica interna:**
1. Validar que `visit_id` existe y pertenece al usuario autenticado
2. Crear registro en `clinical_records`
3. Descontar inventario — actualizar `stock` en cada `inventory_id`
4. Marcar `visit_procedures` como ejecutados
5. Actualizar `visits.status = 'completed'`
6. Actualizar `leads.status = 'done'`
7. Detectar insumos bajo `min_stock` — retornar alertas
8. Registrar en `audit_log`

---

### 6.3 `telegram-webhook` — POST /functions/v1/telegram-webhook

**Propósito:** Recibir callbacks del bot de Telegram (botones inline) y ejecutar acciones en la base de datos.

**Auth:** Validar `X-Telegram-Bot-Api-Secret-Token` header.

**Acciones soportadas (callback_data):**

```
lead_info:{lead_id}        → Responde con detalle completo del lead
lead_whatsapp:{lead_id}    → Responde con deep link wa.me + texto pre-armado
lead_status_progress:{lead_id}  → Cambia lead a 'in_progress'
lead_status_done:{lead_id}      → Cambia lead a 'done'
lead_open_panel:{lead_id}  → Responde con URL directa al panel del lead
```

**Flujo para nuevo lead (mensaje inicial):**
1. Bot recibe trigger desde `create-lead`
2. Envía mensaje con datos del lead + 4 botones inline:
   - 📋 Ver detalle
   - 💬 Abrir WhatsApp
   - 🔄 Marcar en curso
   - 🌐 Abrir panel

**Formato del mensaje inicial:**
```
🐾 *Nuevo lead recibido*

👤 *Cliente:* {nombre} — {telefono}
🐶 *Paciente:* {nombre_animal} ({especie})
🏠 *Ubicación:* {comuna}, {region}
🩺 *Servicio:* {service_type}
📝 *Descripción:* {descripcion}
⏰ *Recibido:* {hora}
```

**Botones inline del mensaje:**
```
[📋 Ver detalle]  [💬 WhatsApp]
[🔄 En curso]     [🌐 Abrir panel]
```

**Respuesta al botón "💬 WhatsApp":**
```
wa.me/56XXXXXXXXX?text=Hola! te hablo desde la clínica a domicilio JP, 
leí tu mensaje por nuestra plataforma web y me gustaría saber más sobre 
el caso de {nombre_animal}. ¿Tienes un momento para conversar?
```

**Respuesta al botón "📋 Ver detalle":**
```
📋 *Detalle del lead*

Estado: {status}
Prioridad: {priority}
Servicio solicitado: {service_type}
Dirección: {address}
Animal: {nombre} | {especie} | {breed}
Descripción completa: {description}
Inventario validado: {si/no}
```

---

### 6.4 `whatsapp-preview` — POST /functions/v1/whatsapp-preview

**Propósito:** Generar el texto pre-armado y el deep link `wa.me` para el panel web.

**Auth:** JWT requerido.

**Input:**
```typescript
{
  lead_id: string
  template: 'initial_contact' | 'visit_confirmation' | 'follow_up' | 'custom'
  custom_text?: string
}
```

**Output:**
```typescript
{
  text: string          // Texto listo para copiar
  whatsapp_url: string  // wa.me/{phone}?text={encoded}
  phone: string
}
```

**Templates disponibles:**

`initial_contact`:
> Hola {nombre_cliente}! te hablo desde la clínica a domicilio JP, leí tu mensaje por nuestra plataforma web y me gustaría saber más sobre el caso de {nombre_animal}. ¿Tienes un momento para conversar?

`visit_confirmation`:
> Hola {nombre_cliente}! confirmo tu visita para {nombre_animal} el {fecha} a las {hora} en {direccion}. Cualquier consulta, escríbeme aquí. ¡Nos vemos pronto! 🐾

`follow_up`:
> Hola {nombre_cliente}! te escribo para hacer seguimiento al caso de {nombre_animal}. ¿Cómo ha estado? ¿Pudiste conseguir {indicacion_pendiente}?

---

### 6.5 `send-email` — POST /functions/v1/send-email

**Propósito:** Enviar emails transaccionales via Resend.

**Auth:** Solo llamada interna desde otras Edge Functions (service_role).

**Templates:**
- `lead_confirmation` — Al cliente cuando envía el formulario
- `lead_new_internal` — Al técnico cuando llega un lead nuevo (backup del Telegram)
- `visit_reminder` — Recordatorio de visita 24h antes
- `stock_alert` — Alerta de stock bajo al admin

---

## 7. RUTAS DEL FRONTEND

### Router (`src/router/index.js`)

```javascript
// RUTAS PÚBLICAS — sin auth
{ path: '/',              component: LandingView,       layout: 'public' }
{ path: '/solicitar',     component: SolicitudView,     layout: 'public' }
{ path: '/confirmacion',  component: ConfirmacionView,  layout: 'public' }
{ path: '/login',         component: LoginView,         layout: 'none'   }

// RUTAS PRIVADAS — auth required
{ path: '/app',                     redirect: '/app/dashboard'     }
{ path: '/app/dashboard',           component: DashboardView       }
{ path: '/app/leads',               component: LeadsView           }
{ path: '/app/leads/:id',           component: LeadDetailView      }
{ path: '/app/agenda',              component: AgendaView          }
{ path: '/app/visitas/:id',         component: VisitaDetailView    }
{ path: '/app/pacientes',           component: PacientesView       }
{ path: '/app/pacientes/:id',       component: PacienteDetailView  }
{ path: '/app/inventario',          component: InventarioView      }
{ path: '/app/procedimientos',      component: ProcedimientosView  }
{ path: '/app/reportes',            component: ReportesView        }
{ path: '/app/configuracion',       component: ConfiguracionView   }
```

### Navigation Guard

```javascript
router.beforeEach(async (to) => {
  const authStore = useAuthStore()
  const isPublic = ['/', '/solicitar', '/confirmacion', '/login'].includes(to.path)

  if (!isPublic && !authStore.user) {
    return '/login'
  }

  if (to.path === '/login' && authStore.user) {
    return '/app/dashboard'
  }
})
```

---

## 8. CONVENCIONES DE CÓDIGO

### Vue 3 — Composition API

- **Siempre** usar `<script setup>` — nunca Options API
- Props siempre con `defineProps` tipadas
- Emits siempre con `defineEmits`
- Composables en `src/composables/` con prefijo `use`
- Stores en `src/stores/` con `defineStore` de Pinia

```vue
<!-- ✅ Correcto -->
<script setup>
import { ref, computed, onMounted } from 'vue'
import { useLeadsStore } from '@/stores/leads'

const props = defineProps({
  leadId: { type: String, required: true }
})

const emit = defineEmits(['status-changed'])
const leadsStore = useLeadsStore()
</script>

<!-- ❌ Incorrecto — nunca usar Options API -->
<script>
export default {
  data() { return {} }
}
</script>
```

### Tailwind CSS

- No crear clases CSS custom salvo para variables GSAP o casos imposibles con Tailwind
- Mobile-first: `sm:`, `md:`, `lg:` breakpoints
- Colores del sistema definidos en `tailwind.config.js` como `brand.*`
- No usar estilos inline — todo en clases Tailwind

### GSAP

- Importar solo lo necesario: `import { gsap } from 'gsap'`
- Animaciones de entrada de componentes en `onMounted`
- Animaciones de salida en `onBeforeUnmount`
- Usar `useGsap` composable para animaciones recurrentes
- Registrar plugins globalmente en `main.js`

```javascript
// src/main.js
import { gsap } from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'
gsap.registerPlugin(ScrollTrigger)
```

### Servicios (acceso a Supabase)

- **Nunca** llamar a Supabase directamente desde componentes o stores
- Toda query pasa por `src/services/*.service.js`
- Los stores llaman a los servicios
- Los componentes llaman a los stores o composables

```javascript
// ✅ Correcto
// componente → store → service → supabase

// ❌ Incorrecto — nunca en un componente
import { supabase } from '@/services/supabase'
const { data } = await supabase.from('leads').select('*')
```

### Manejo de errores

- Toda operación async envuelta en try/catch
- Errores de Supabase loggeados con contexto
- Errores de UI mostrados via `useToast()`
- Nunca exponer mensajes de error internos al usuario público

### Nomenclatura

| Tipo | Convención | Ejemplo |
|---|---|---|
| Componentes | PascalCase | `LeadCard.vue` |
| Composables | camelCase con `use` | `useLeads.js` |
| Stores | camelCase con `use` + `Store` | `useLeadsStore` |
| Servicios | camelCase con `.service` | `leads.service.js` |
| Variables/funciones | camelCase | `fetchLeadById` |
| Constantes | SCREAMING_SNAKE | `LEAD_STATUS` |
| CSS classes | kebab-case | `lead-card` |

---

## 9. BOT DE TELEGRAM

### Setup

1. Crear bot con @BotFather → obtener `BOT_TOKEN`
2. Configurar webhook apuntando a la Edge Function:
   ```
   POST https://api.telegram.org/bot{TOKEN}/setWebhook
   { "url": "https://{project}.supabase.co/functions/v1/telegram-webhook",
     "secret_token": "{TELEGRAM_WEBHOOK_SECRET}" }
   ```
3. Registrar el `telegram_id` del técnico en la tabla `users`

### Flujo completo de notificación

```
[Formulario web] → Edge Function create-lead
                          ↓
              Guarda lead en Supabase
                          ↓
              Llama a Telegram Bot API
                          ↓
        Bot envía mensaje al técnico con botones
                          ↓
        Técnico presiona botón (callback_query)
                          ↓
        Webhook recibe callback → Edge Function telegram-webhook
                          ↓
        Ejecuta acción en Supabase + responde al bot
                          ↓
        Bot actualiza/edita el mensaje original
```

### Variables de entorno del bot

```
TELEGRAM_BOT_TOKEN=
TELEGRAM_WEBHOOK_SECRET=
TELEGRAM_ADMIN_CHAT_ID=      # Chat ID del técnico principal
```

### Seguridad del webhook

- Validar `X-Telegram-Bot-Api-Secret-Token` en cada request
- Verificar que el `chat_id` del callback está autorizado en `users.telegram_id`
- Rate limiting implícito en Supabase Edge Functions

---

## 10. FORMULARIO PÚBLICO — MULTI-PASO

El formulario de `/solicitar` tiene 4 pasos con validación por paso. Usar GSAP para transición entre pasos.

### Paso 1: Sobre ti
- Nombre completo (required)
- Teléfono (required, validar formato +56)
- Email (opcional)
- Región (select, required)
- Comuna (input, required)
- Dirección (required)

### Paso 2: Tu mascota
- Nombre del animal (required)
- Especie (select required): perro, gato, ave, gallina, caballo, bovino, otro
- Raza (opcional)
- Edad aproximada (opcional)
- Sexo (select): macho, hembra, desconocido

### Paso 3: ¿Qué necesitas?
- Tipo de servicio (select required): vacunación, desparasitación, chequeo, receta, corte de pelo, atención a domicilio, otro
- Descripción del caso (textarea, required, min 20 chars)
- Urgencia (radio): normal, urgente

### Paso 4: Confirmación
- Resumen de todos los datos
- Botón "Enviar solicitud"
- POST a Edge Function `create-lead`
- Redirect a `/confirmacion`

---

## 11. DASHBOARD — MÉTRICAS Y ALERTAS

### Métricas principales (KPIs)

```
Leads hoy          — COUNT leads WHERE DATE(created_at) = TODAY
Leads en espera    — COUNT leads WHERE status = 'waiting'
Leads en curso     — COUNT leads WHERE status = 'in_progress'
Visitas esta semana — COUNT visits WHERE scheduled_at BETWEEN start_week AND end_week
Tasa de cierre     — (done / total leads) * 100 (últimos 30 días)
```

### Alertas activas (panel lateral)

```
Stock crítico      — inventory WHERE stock <= min_stock
Leads sin respuesta — leads WHERE status='waiting' AND created_at < NOW() - INTERVAL '2 hours'
Visitas próximas   — visits WHERE scheduled_at BETWEEN NOW() AND NOW() + INTERVAL '24 hours'
```

### Accesos rápidos

- Nuevo lead manual
- Ver agenda hoy
- Revisar stock crítico
- Último lead recibido

---

## 12. VARIABLES DE ENTORNO

### `.env.example` (commitear este archivo)

```bash
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
```

### Reglas críticas de variables

- Prefijo `VITE_` **solo** para variables que necesita el frontend
- `SUPABASE_SERVICE_ROLE_KEY` **nunca** en frontend — solo Edge Functions
- `TELEGRAM_BOT_TOKEN` **nunca** en frontend
- `RESEND_API_KEY` **nunca** en frontend

---

## 13. REGLAS DE NEGOCIO — CRÍTICAS

Estas reglas deben estar implementadas en Edge Functions o triggers SQL, **no solo en el frontend**.

1. **Todo lead nuevo entra en `waiting`** — nunca en otro estado
2. **El descuento de inventario ocurre SOLO al cerrar la visita** — no al crearla ni confirmarla
3. **Una ficha clínica se crea UNA sola vez por visita** — relación 1:1 enforced por UNIQUE constraint
4. **Un lead no puede pasar de `waiting` a `done` directamente** — debe pasar por `in_progress`
5. **Si un procedimiento requiere insumos insuficientes**, el sistema debe alertar pero NO bloquear — el técnico decide
6. **Toda acción crítica genera registro en `audit_log`**: cambio de estado de lead, cierre de visita, modificación de inventario, creación/edición de ficha clínica
7. **El cliente nunca tiene acceso al panel interno** — las rutas `/app/*` requieren auth obligatoria
8. **El `asistente` no puede modificar inventory** — solo lectura para validar disponibilidad
9. **El teléfono del cliente se normaliza a formato `+56XXXXXXXXX`** antes de guardar
10. **No eliminar leads ni fichas clínicas** — solo soft delete o cambio de estado

---

## 14. PLAN DE IMPLEMENTACIÓN

### Fase 1 — Core MVP (semanas 1–3)

- [ ] Setup proyecto Vite + Vue 3 + Tailwind + GSAP
- [ ] Setup Supabase: migrations, RLS, tablas base
- [ ] Auth: login, sesión, guard de rutas
- [ ] Edge Function: `create-lead`
- [ ] Formulario público multi-paso (`/solicitar`)
- [ ] Dashboard básico con métricas
- [ ] Pipeline de leads (lista + cambio de estado)
- [ ] Bot Telegram: notificación + botones inline
- [ ] Edge Function: `telegram-webhook`

### Fase 2 — Operación completa (semanas 4–6)

- [ ] Agenda / calendario de visitas
- [ ] Detalle de visita + formulario de cierre
- [ ] Edge Function: `close-visit`
- [ ] Fichas clínicas (creación y visualización)
- [ ] Historial clínico por animal
- [ ] CRUD inventario completo + alertas de stock
- [ ] CRUD procedimientos + relación con insumos
- [ ] WhatsApp preview: templates + deep link
- [ ] Email transaccional via Resend
- [ ] Perfil de paciente completo

### Fase 3 — Refinamiento y escala (semanas 7–9)

- [ ] Reportes y métricas avanzadas
- [ ] Rol `asistente`: onboarding y vistas restringidas
- [ ] Upload de fotos de pacientes (Supabase Storage)
- [ ] Upload de manuales PDF de proveedores
- [ ] Optimización de queries y caching
- [ ] Landing pública pulida con GSAP
- [ ] PWA básica (offline-ready para campo)
- [ ] Tests de flujos críticos

---

## 15. SETUP LOCAL

```bash
# 1. Clonar repo
git clone https://github.com/vi-studio/vetdesk
cd vetdesk

# 2. Instalar dependencias
npm install

# 3. Variables de entorno
cp .env.example .env.local
# Editar .env.local con las credenciales reales

# 4. Inicializar Supabase CLI
npx supabase init
npx supabase link --project-ref {PROJECT_REF}

# 5. Correr migraciones
npx supabase db push

# 6. Deploy de Edge Functions
npx supabase functions deploy create-lead
npx supabase functions deploy close-visit
npx supabase functions deploy telegram-webhook
npx supabase functions deploy whatsapp-preview
npx supabase functions deploy send-email

# 7. Configurar webhook de Telegram
curl -X POST "https://api.telegram.org/bot{TOKEN}/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://{PROJECT}.supabase.co/functions/v1/telegram-webhook",
       "secret_token": "{WEBHOOK_SECRET}"}'

# 8. Dev server
npm run dev
```

---

## 16. CRITERIOS DE ACEPTACIÓN DEL MVP

- [ ] El técnico recibe una notificación en Telegram en menos de 10 segundos tras el envío del formulario
- [ ] El técnico puede cambiar el estado de un lead desde Telegram sin abrir el navegador
- [ ] El sistema genera el texto de WhatsApp pre-armado con datos reales del lead con un clic
- [ ] El inventario alerta insumos faltantes antes de confirmar una visita
- [ ] Cada cierre de visita genera automáticamente una ficha clínica
- [ ] El historial clínico de un animal es accesible desde su perfil en menos de 2 clics
- [ ] El panel funciona correctamente en móvil (técnico en campo)
- [ ] Toda acción crítica queda registrada en audit_log
- [ ] El sistema puede operar sin internet momentáneo (PWA Fase 3)

---

## 17. DECISIONES DIFERIDAS (no implementar en MVP)

- Pagos en línea / facturación
- App móvil nativa
- Multi-clínica / multi-negocio
- Chat interno entre técnicos
- Integración con API oficial de WhatsApp Business
- Telemedicina / videollamadas
- Recordatorios automáticos de vacunación
- Exportación a SAT / SII

---

*Documento generado por Vi_Studio. Versión 1.0 — Abril 2026.*
*Todo cambio de arquitectura, modelo de datos o reglas de negocio debe reflejarse en este documento antes de implementarse.*