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

export const VISIT_STATUS_LABELS = {
  scheduled:   'Programada',
  confirmed:   'Confirmada',
  in_progress: 'En curso',
  completed:   'Completada',
  cancelled:  'Cancelada',
}

export const VISIT_STATUS_COLORS = {
  scheduled:   'bg-blue-500/20 text-blue-400 border-blue-500/30',
  confirmed:   'bg-teal-500/20 text-teal-400 border-teal-500/30',
  in_progress: 'bg-amber-500/20 text-amber-400 border-amber-500/30',
  completed:   'bg-brand-500/20 text-brand-400 border-brand-500/30',
  cancelled:   'bg-slate-500/20 text-slate-400 border-slate-500/30',
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
