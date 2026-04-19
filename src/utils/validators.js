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

// RUT validation (formato: 12.345.678-9 o 12345678-9)
export function isValidRUT(rut) {
  const cleaned = rut?.replace(/[^0-9kK]/g, '')
  if (!cleaned || cleaned.length < 2) return false
  const match = cleaned.match(/^(\d+)([0-9kK])$/)
  if (!match) return false
  const [, num, dv] = match
  const body = num
  let sum = 0, mul = 2
  for (let i = body.length - 1; i >= 0; i--) {
    sum += parseInt(body[i]) * mul++
    if (mul > 7) mul = 2
  }
  const expected = (11 - (sum % 11)).toString()
  const expectedDV = expected === '11' ? '0' : expected === '10' ? 'k' : expected
  return expectedDV === dv.toLowerCase()
}

export function normalizeRUT(rut) {
  return rut?.replace(/[^0-9kK]/g, '').toLowerCase()
}

// Formatea un RUT normalizado o crudo a 12.345.678-9
export function formatRUT(rut) {
  if (!rut) return ''
  const clean = rut.replace(/[^0-9kK]/g, '')
  if (clean.length < 2) return rut
  const dv   = clean.slice(-1).toUpperCase()
  const body = clean.slice(0, -1)
  const formatted = body.replace(/\B(?=(\d{3})+(?!\d))/g, '.')
  return `${formatted}-${dv}`
}
