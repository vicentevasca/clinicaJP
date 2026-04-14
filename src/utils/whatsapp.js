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
