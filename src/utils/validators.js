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
