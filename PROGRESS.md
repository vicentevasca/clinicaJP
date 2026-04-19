# VetDesk — Progress Log
> Última actualización: 19 Abril 2026

---

## Estado general del proyecto

**Fase actual:** Fase 1 completada + avances significativos de Fase 2
**Deploy frontend:** Vercel (CI/CD desde `main`)
**Backend:** Supabase Cloud (PostgreSQL + Edge Functions + RLS)

---

## Migraciones aplicadas en producción

| # | Archivo | Descripción | Estado |
|---|---------|-------------|--------|
| 001 | `001_initial_schema.sql` | Schema base: users, clients, animals, leads, visits, procedures, inventory, clinical_records, audit_log | ✅ Aplicada |
| 002 | `002_rls_policies.sql` | Row Level Security en todas las tablas | ✅ Aplicada |
| 003 | `003_functions.sql` | Funciones SQL auxiliares (get_user_role, update_updated_at_column) | ✅ Aplicada |
| 004 | `004_triggers.sql` | Triggers updated_at automáticos | ✅ Aplicada |
| 005 | `005_mi_mascota.sql` | Soporte para portal público Mi Mascota | ✅ Aplicada |
| 006 | `006_vaccinations.sql` | Tabla `vaccinations` con RLS, índices y trigger | ✅ Aplicada |
| 007 | `007_clients_rut.sql` | Columna `rut` en `clients`, índice único parcial | ✅ Aplicada |

---

## Edge Functions

| Función | Ruta | Estado | Notas |
|---------|------|--------|-------|
| `create-lead` | POST /functions/v1/create-lead | ⚠️ Redesplegar | Actualizada: guarda RUT, busca por teléfono y RUT, notificación Telegram |
| `close-visit` | POST /functions/v1/close-visit | ✅ Desplegada | Cierre de visita, descuento inventario, alertas de stock |
| `telegram-webhook` | POST /functions/v1/telegram-webhook | ✅ Desplegada | Callbacks de botones inline del bot |
| `whatsapp-preview` | POST /functions/v1/whatsapp-preview | ✅ Desplegada | Templates de mensajes con deep link |
| `send-email` | POST /functions/v1/send-email | ✅ Desplegada | Email transaccional via Resend |
| `get-client-portal-data` | GET /functions/v1/get-client-portal-data | ⚠️ Redesplegar | Actualizada: retorna vacunas de tabla dedicada por animal |

**Comando para redesplegar:**
```bash
npx supabase functions deploy create-lead
npx supabase functions deploy get-client-portal-data
```

---

## Panel de administración interno (`/app/*`)

| Vista | Ruta | Estado |
|-------|------|--------|
| Login | `/login` | ✅ Completo |
| Dashboard | `/app/dashboard` | ✅ Completo — métricas en vivo, alertas de stock, leads sin respuesta |
| Leads Kanban | `/app/leads` | ✅ Completo — pipeline 4 columnas, filtros, cambio de estado |
| Detalle Lead | `/app/leads/:id` | ✅ Completo — timeline, WhatsApp, visita asociada, RUT del cliente |
| Agenda | `/app/agenda` | ✅ Completo — calendario mensual, visitas por día |
| Detalle Visita | `/app/visitas/:id` | ✅ Completo — workflow de estados, ficha obligatoria antes de cerrar, vacunas |
| Pacientes | `/app/pacientes` | ✅ Completo — grid con filtros por especie |
| Detalle Paciente | `/app/pacientes/:id` | ✅ Completo — tabs: Historial clínico / Vacunas / Evolución de peso |
| Inventario | `/app/inventario` | ✅ Completo — CRUD, alertas de stock crítico, tabs por categoría |
| Procedimientos | `/app/procedimientos` | ✅ Completo — CRUD, insumos vinculados |
| Reportes | `/app/reportes` | ✅ Funcional — métricas por período (sin gráficos interactivos aún) |
| Configuración | `/app/configuracion` | ✅ Completo — perfil de usuario |

---

## Portal público (`/mi-mascota`)

| Feature | Estado |
|---------|--------|
| Búsqueda por RUT | ✅ Completo — valida dígito verificador, busca en `clients.rut` |
| Búsqueda por teléfono | ✅ Completo — fallback para clientes sin RUT |
| Historial clínico | ✅ Completo — timeline con peso, temperatura, diagnóstico, tratamiento |
| Vacunas — tabla dedicada | ✅ Completo — lote, laboratorio, alerta de vencimiento rojo/ámbar |
| Vacunas — fallback keywords | ✅ Completo — para registros previos a la tabla `vaccinations` |
| Evolución de peso | ✅ Completo — gráfico de barras + tabla, diferencia vs visita anterior |
| Solicitar nueva visita | ✅ Completo — modal conectado a Edge Function `create-lead` |

---

## Formulario público (`/solicitar`)

| Campo | Estado |
|-------|--------|
| Nombre completo | ✅ Requerido |
| RUT | ✅ Requerido — validación dígito verificador, normalizado al guardar |
| Teléfono | ✅ Requerido — formato +56 |
| Email | ✅ Opcional |
| Región / Comuna / Dirección | ✅ Requeridos |
| Datos del animal | ✅ Especie y nombre requeridos |
| Tipo de servicio + descripción | ✅ Requeridos |
| Urgencia | ✅ Normal / Urgente |
| Flujo multi-paso (4 pasos) | ✅ Con GSAP, resumen con RUT formateado en confirmación |

---

## Sistema clínico

| Feature | Estado |
|---------|--------|
| Ficha clínica por visita | ✅ Peso, temperatura, diagnóstico, tratamiento, receta, observaciones, próxima visita |
| Cierre de visita bloqueado sin ficha | ✅ Botón deshabilitado hasta guardar la ficha |
| Actualización automática de peso | ✅ Al guardar ficha, actualiza `animals.weight_kg` |
| Historial de peso en panel | ✅ Mini gráfico + tabla en detalle de paciente |
| Registro de vacunas por visita | ✅ Múltiples vacunas, presets, lote, laboratorio, próxima dosis |
| Historial de vacunas en panel | ✅ Alertas vencimiento, accesible en detalle de paciente |
| Timeline clínico | ✅ Muestra peso, temperatura y próxima visita recomendada |

---

## Fixes resueltos

| Issue | Solución |
|-------|----------|
| Router guard redundante devolvía `/login` en ambos casos | Corregido: logueado → `/app/dashboard`, anónimo → `/login` |
| `inventoryService.getLowStock()` comparaba contra `0` en vez de `min_stock` | Corregido a filtro JS `stock <= min_stock` |
| Notificaciones en Configuración eran checkboxes mock sin persistencia | Reemplazados por mensaje "próximamente" |
| `ClinicalTimelineItem` no mostraba el peso ni la recomendación | Agregados ⚖️ peso y próxima visita |
| `animals.weight_kg` nunca se actualizaba con visitas nuevas | Auto-update al guardar ficha clínica |
| Tab Vacunas en portal usaba detección por palabras clave | Migrado a tabla `vaccinations` con fallback para registros viejos |

---

## Pendiente

### Alta prioridad
- [ ] Redesplegar `create-lead` y `get-client-portal-data`
- [ ] Probar flujo completo end-to-end: formulario → lead → visita → ficha → vacunas → portal por RUT
- [ ] Agregar confirmación modal antes de eliminar/desactivar en inventario y procedimientos

### Media prioridad
- [ ] Gráficos interactivos en Reportes (Chart.js o similar)
- [ ] Drag & drop en el Kanban de leads
- [ ] Operaciones en lote (cambiar estado de múltiples leads)
- [ ] Exportar reportes a CSV

### Fase 3 (baja prioridad)
- [ ] PWA / offline — `sw.js` referenciado en `main.js` pero no creado
- [ ] Upload de fotos de pacientes (Supabase Storage)
- [ ] Upload de manuales PDF de proveedores (Supabase Storage)
- [ ] Landing pública pulida con GSAP avanzado
- [ ] Rol `asistente`: vistas y restricciones
- [ ] Tests de flujos críticos

---

## Criterios de aceptación del MVP

| Criterio | Estado |
|----------|--------|
| Notificación Telegram en < 10s tras formulario | ✅ |
| Cambio de estado de lead desde Telegram sin abrir navegador | ✅ |
| WhatsApp pre-armado con datos reales del lead | ✅ |
| Inventario alerta insumos faltantes antes de confirmar visita | ✅ |
| Cierre de visita genera ficha clínica (ahora obligatorio) | ✅ |
| Historial clínico accesible en < 2 clics | ✅ |
| Panel funciona en móvil | ✅ |
| Toda acción crítica queda en audit_log | ✅ |
| Sistema opera sin internet momentáneo (PWA) | ⏳ Fase 3 |
