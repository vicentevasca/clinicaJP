/**
 * VetDesk — Seed Script
 * Run: node scripts/seed.js
 * Uses Supabase REST Admin API with service_role key (bypasses RLS)
 */
const SUPABASE_URL = 'https://nijpbzmvtfranlghejip.supabase.co'
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5panBiem12dGZyYW5sZ2hlamlwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjE4ODQ2NiwiZXhwIjoyMDkxNzY0NDY2fQ.i2DU_OscdxOFzJidNpxiAy2WSZVBrLeJQlBFR0n7HiU'

async function supabaseRequest(method, path, body) {
  const res = await fetch(`${SUPABASE_URL}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      apikey: SERVICE_KEY,
      Authorization: `Bearer ${SERVICE_KEY}`,
    },
    body: body ? JSON.stringify(body) : undefined,
  })
  const text = await res.text()
  if (!res.ok) throw new Error(`[${method} ${path}] ${res.status} ${text}`)
  if (!text) return []
  try { return JSON.parse(text) } catch { return text }
}

async function upsert(table, data, matchField) {
  const matchVal = data[matchField]
  // Check if exists
  const existing = await supabaseRequest('GET', `/rest/v1/${table}?${matchField}=eq.${encodeURIComponent(matchVal)}&limit=1`)
  if (existing.length > 0) {
    console.log(`  ↪ ${table}: "${matchVal}" ya existe, omitido`)
    return existing[0]
  }
  // Insert
  await supabaseRequest('POST', `/rest/v1/${table}`, data)
  // Fetch the created row
  const created = await supabaseRequest('GET', `/rest/v1/${table}?${matchField}=eq.${encodeURIComponent(matchVal)}&limit=1`)
  console.log(`  ✓ ${table}: "${matchVal}" creado`)
  return created[0]
}

async function seed() {
  console.log('\n🌱 VetDesk Seed — Starting...\n')

  // ── 1. Procedures ─────────────────────────────────────────────────────────
  console.log('📋 Insertando procedimientos...')
  const procedures = [
    { name: 'Vacunación básica', description: 'Vacuna según esquema obligatorio (moquillo, parvovirus, hepatitis)', category: 'vacunacion', duration_min: 20, base_price: 15000 },
    { name: 'Vacunación antirrábica', description: 'Vacuna antirrábica anual obligatoria', category: 'vacunacion', duration_min: 15, base_price: 8000 },
    { name: 'Desparasitación interna', description: 'Pastilla o inyección antihelmíntica', category: 'desparasitacion', duration_min: 15, base_price: 6000 },
    { name: 'Desparasitación externa', description: 'Producto antiparasitario externo (pipeta o spray)', category: 'desparasitacion', duration_min: 10, base_price: 5000 },
    { name: 'Chequeo general', description: 'Examen físico completo: piel, ojos, oídos, dentadura, corazón, pulmones', category: 'chequeo', duration_min: 30, base_price: 12000 },
    { name: 'Chequeo cardiológico', description: 'Evaluación cardiovascular con énfasis en razas predispuestas', category: 'chequeo', duration_min: 40, base_price: 20000 },
    { name: 'Receta médica', description: 'Emitir receta para medicamento específico', category: 'receta', duration_min: 10, base_price: 5000 },
    { name: 'Corte de pelo y baño', description: 'Baño, corte de pelo, limpieza de oídos y corte de uñas', category: 'corte_pelo', duration_min: 60, base_price: 18000 },
    { name: 'Atención a domicilio', description: 'Visita veterinaria general a domicilio (sin procedimiento adicional)', category: 'atencion_domicilio', duration_min: 30, base_price: 20000 },
    { name: 'Curaciones menores', description: 'Limpieza y curación de heridas superficiales', category: 'atencion_domicilio', duration_min: 20, base_price: 8000 },
    { name: 'Aplicación de medicamento', description: 'Administración de inyección subcutánea o intramuscular', category: 'atencion_domicilio', duration_min: 10, base_price: 4000 },
    { name: 'Toma de muestras', description: 'Extracción de sangre o muestra para laboratorio', category: 'chequeo', duration_min: 20, base_price: 10000 },
  ]

  const seededProcedures = []
  for (const p of procedures) {
    const created = await upsert('procedures', { ...p, active: true }, 'name')
    seededProcedures.push(created)
  }

  // ── 2. Inventory ──────────────────────────────────────────────────────────
  console.log('\n📦 Insertando inventario...')
  const inventoryItems = [
    // Vacunas
    { name: 'Vacuna moquillo', description: 'Vacuna antipartovirósica canina', category: 'vacuna', stock: 20, min_stock: 5, unit: 'dosis', cost_per_unit: 3500, supplier_name: 'Centauro Lab' },
    { name: 'Vacuna parvovirus', description: 'Vacuna antiadenovirus canina', category: 'vacuna', stock: 18, min_stock: 5, unit: 'dosis', cost_per_unit: 3000, supplier_name: 'Centauro Lab' },
    { name: 'Vacuna antirrábica', description: 'Vacuna rábica anual', category: 'vacuna', stock: 25, min_stock: 5, unit: 'dosis', cost_per_unit: 2500, supplier_name: 'ISP Chile' },
    { name: 'Vacuna triple felina', description: 'Panleucopenia, rinotraqueítis, calcivirosis felina', category: 'vacuna', stock: 15, min_stock: 3, unit: 'dosis', cost_per_unit: 5000, supplier_name: 'Virbac' },
    // Fármacos
    { name: 'Ivermectina 1%', description: 'Antiparasitario interno inyectable', category: 'farmaco', stock: 30, min_stock: 8, unit: 'ml', cost_per_unit: 800, supplier_name: 'Synthon' },
    { name: 'Albendazol', description: 'Desparasitante oral de amplio espectro', category: 'farmaco', stock: 40, min_stock: 10, unit: 'comprimidos', cost_per_unit: 200, supplier_name: 'Synthon' },
    { name: 'Amoxicilina 250mg', description: 'Antibiótico de amplio espectro', category: 'farmaco', stock: 60, min_stock: 15, unit: 'comprimidos', cost_per_unit: 150, supplier_name: 'Sanderson' },
    { name: 'Meloxicam 5mg', description: 'Antiinflamatorio y analgésico', category: 'farmaco', stock: 50, min_stock: 10, unit: 'comprimidos', cost_per_unit: 300, supplier_name: 'Boehringer' },
    { name: 'Enrofloxacina 50mg', description: 'Antibiótico fluoroquinolona', category: 'farmaco', stock: 25, min_stock: 5, unit: 'comprimidos', cost_per_unit: 450, supplier_name: 'Bayer' },
    { name: 'Vitamina B12', description: 'Complejo vitamínico B inyectable', category: 'farmaco', stock: 20, min_stock: 5, unit: 'ml', cost_per_unit: 600, supplier_name: 'Chile' },
    { name: 'Suero fisiológico 500ml', description: 'Solución salina para fluidoterapia', category: 'farmaco', stock: 10, min_stock: 3, unit: 'bolsas', cost_per_unit: 1200, supplier_name: 'Biosano' },
    // Insumos
    { name: 'Jeringas 5ml', description: 'Jeringas desechables estériles', category: 'insumo', stock: 100, min_stock: 20, unit: 'unidades', cost_per_unit: 150, supplier_name: 'Terumo' },
    { name: 'Jeringas 1ml', description: 'Jeringas para insulina o疫苗', category: 'insumo', stock: 80, min_stock: 20, unit: 'unidades', cost_per_unit: 100, supplier_name: 'Terumo' },
    { name: 'Gasas estériles', description: 'Gasas en paquete 10x10cm', category: 'insumo', stock: 50, min_stock: 10, unit: 'paquetes', cost_per_unit: 800, supplier_name: '3M' },
    { name: 'Vendas elásticas', description: 'Vendas cohesivas para vendajes', category: 'insumo', stock: 30, min_stock: 5, unit: 'rollos', cost_per_unit: 600, supplier_name: '3M' },
    { name: 'Guantes de examen M', description: 'Guantes de nitrilo desechables', category: 'insumo', stock: 200, min_stock: 50, unit: 'cajas', cost_per_unit: 2500, supplier_name: 'Sempermed' },
    { name: 'Alcohol gel 500ml', description: 'Desinfectante de manos', category: 'insumo', stock: 10, min_stock: 3, unit: 'botellas', cost_per_unit: 2000, supplier_name: 'Ecolab' },
    { name: 'Pipetas antiparasitarias', description: 'Pipetas spot-on para perros medianos', category: 'insumo', stock: 12, min_stock: 3, unit: 'pipetas', cost_per_unit: 3500, supplier_name: 'Merial' },
    // Herramientas
    { name: 'Termómetro digital', description: 'Termómetro clínico digital rápido', category: 'herramienta', stock: 2, min_stock: 1, unit: 'unidades', cost_per_unit: 8000, supplier_name: 'Omron' },
    { name: 'Estetoscopio', description: 'Estetoscopio clínico veterinario', category: 'herramienta', stock: 1, min_stock: 1, unit: 'unidades', cost_per_unit: 25000, supplier_name: 'Littmann' },
    { name: 'Tijeras de cura', description: 'Tijeras romas para cura', category: 'herramienta', stock: 3, min_stock: 1, unit: 'unidades', cost_per_unit: 5000, supplier_name: 'Acero' },
    { name: 'Báscula digital', description: 'Báscula para weighing animales pequeños', category: 'herramienta', stock: 1, min_stock: 1, unit: 'unidades', cost_per_unit: 15000, supplier_name: 'Tanita' },
    { name: 'Bolsas para muestras', description: 'Bolsas estériles para muestras clínicas', category: 'insumo', stock: 40, min_stock: 10, unit: 'bolsas', cost_per_unit: 300, supplier_name: 'Sarstedt' },
  ]

  for (const item of inventoryItems) {
    await upsert('inventory', { ...item, active: true }, 'name')
  }

  // ── 3. Working hours (lunes a viernes 8:00-20:00) ────────────────────────
  console.log('\n🕐 Insertando horarios de trabajo...')
  // Upsert a minimal user first (admin/tecnico)
  const adminEmail = 'vetdesk@clinicajp.cl'
  let adminUser = await supabaseRequest('GET', `/rest/v1/users?email=eq.${encodeURIComponent(adminEmail)}&limit=1`)
  if (adminUser.length === 0) {
    // We can't create auth.users here directly; skip if no user exists yet
    console.log('  ⚠️ No se encontró usuario admin, saltando working_hours')
  } else {
    adminUser = adminUser[0]
    const daysOfWeek = [
      { day: 1, label: 'Lunes' }, { day: 2, label: 'Martes' }, { day: 3, label: 'Miércoles' },
      { day: 4, label: 'Jueves' }, { day: 5, label: 'Viernes' },
    ]
    for (const { day } of daysOfWeek) {
      await supabaseRequest('POST', '/rest/v1/working_hours', {
        user_id: adminUser.id,
        day_of_week: day,
        start_time: '08:00',
        end_time: '20:00',
        active: true,
      }).catch(() => {
        // Ignore duplicate key — already exists
      })
    }
    console.log('  ✓ working_hours: Lunes-Viernes 8:00-20:00')
  }

  console.log('\n✅ Seed completado!\n')
  console.log('   Procedimientos:', procedures.length)
  console.log('   Inventario:', inventoryItems.length)
  console.log('\nAhora puedes hacer deploy de las Edge Functions con:')
  console.log('   npx supabase functions deploy create-lead')
  console.log('   npx supabase functions deploy telegram-webhook')
  console.log('   npx supabase functions deploy close-visit')
  console.log('   npx supabase functions deploy whatsapp-preview')
  console.log('   npx supabase functions deploy send-email')
  console.log('\nY configurar el webhook de Telegram:')
  console.log('   curl -X POST "https://api.telegram.org/bot8662662849:AAFMxOqB47pb-2fvXvYEDsXucxlIV2ej2lE/setWebhook" \\')
  console.log('     -H "Content-Type: application/json" \\')
  console.log('     -d \'{"url": "https://nijpbzmvtfranlghejip.supabase.co/functions/v1/telegram-webhook", "secret_token": "vetdesk_telegram_secret_2024"}\'')
  console.log('')
}

seed().catch(err => {
  console.error('❌ Seed falló:', err)
  process.exit(1)
})
