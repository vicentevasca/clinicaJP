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
