-- VetDesk — Schema inicial
-- Ejecutar en orden: 001 → 002 → 003 → 004

-- Extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla users (extiende auth.users de Supabase)
CREATE TABLE users (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  email       TEXT NOT NULL UNIQUE,
  role        TEXT NOT NULL CHECK (role IN ('admin', 'tecnico', 'asistente')),
  phone       TEXT,
  telegram_id BIGINT UNIQUE,
  active      BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- clients
CREATE TABLE clients (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT NOT NULL,
  phone      TEXT NOT NULL,
  email      TEXT,
  region     TEXT,
  comuna     TEXT,
  address    TEXT,
  notes      TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- animals
CREATE TABLE animals (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id   UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  species     TEXT NOT NULL CHECK (species IN ('perro','gato','ave','gallina','caballo','bovino','otro')),
  breed       TEXT,
  birth_date  DATE,
  sex         TEXT CHECK (sex IN ('macho','hembra','desconocido')),
  weight_kg   NUMERIC(5,2),
  photo_url   TEXT,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- leads
CREATE TABLE leads (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id           UUID REFERENCES clients(id),
  animal_id           UUID REFERENCES animals(id),
  assigned_to         UUID REFERENCES users(id),
  status              TEXT NOT NULL DEFAULT 'waiting'
                        CHECK (status IN ('waiting','in_progress','done','cancelled')),
  service_type        TEXT NOT NULL,
  description         TEXT,
  priority            TEXT DEFAULT 'normal' CHECK (priority IN ('low','normal','high','urgent')),
  confidence_score    INTEGER DEFAULT 50 CHECK (confidence_score BETWEEN 0 AND 100),
  source              TEXT DEFAULT 'web_form'
                        CHECK (source IN ('web_form','telegram','whatsapp','phone','referral')),
  inventory_checked   BOOLEAN DEFAULT FALSE,
  inventory_ok        BOOLEAN,
  telegram_message_id BIGINT,
  notes               TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- lead_status_history
CREATE TABLE lead_status_history (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id     UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  from_status TEXT,
  to_status   TEXT NOT NULL,
  changed_by  UUID REFERENCES users(id),
  note        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- visits
CREATE TABLE visits (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id      UUID NOT NULL REFERENCES leads(id),
  animal_id    UUID NOT NULL REFERENCES animals(id),
  client_id    UUID NOT NULL REFERENCES clients(id),
  assigned_to  UUID NOT NULL REFERENCES users(id),
  scheduled_at TIMESTAMPTZ NOT NULL,
  duration_min INTEGER DEFAULT 60,
  status       TEXT NOT NULL DEFAULT 'scheduled'
                 CHECK (status IN ('scheduled','confirmed','in_progress','completed','cancelled')),
  address      TEXT NOT NULL,
  notes        TEXT,
  completed_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- procedures
CREATE TABLE procedures (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL,
  description  TEXT,
  category     TEXT NOT NULL CHECK (category IN ('vacunacion','desparasitacion','chequeo','receta','corte_pelo','atencion_domicilio','otro')),
  duration_min INTEGER DEFAULT 30,
  base_price   NUMERIC(10,2),
  active       BOOLEAN DEFAULT TRUE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- inventory
CREATE TABLE inventory (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name           TEXT NOT NULL,
  description    TEXT,
  category       TEXT NOT NULL CHECK (category IN ('vacuna','farmaco','insumo','herramienta')),
  stock          NUMERIC(10,2) NOT NULL DEFAULT 0,
  min_stock      NUMERIC(10,2) NOT NULL DEFAULT 0,
  unit           TEXT NOT NULL DEFAULT 'unidad',
  cost_per_unit  NUMERIC(10,2),
  manual_url     TEXT,
  supplier_name  TEXT,
  supplier_phone TEXT,
  supplier_email TEXT,
  active         BOOLEAN DEFAULT TRUE,
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  updated_at     TIMESTAMPTZ DEFAULT NOW()
);

-- procedure_inventory (N:M)
CREATE TABLE procedure_inventory (
  procedure_id UUID NOT NULL REFERENCES procedures(id) ON DELETE CASCADE,
  inventory_id UUID NOT NULL REFERENCES inventory(id) ON DELETE CASCADE,
  quantity     NUMERIC(10,3) NOT NULL DEFAULT 1,
  notes        TEXT,
  PRIMARY KEY (procedure_id, inventory_id)
);

-- visit_procedures
CREATE TABLE visit_procedures (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  visit_id     UUID NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
  procedure_id UUID NOT NULL REFERENCES procedures(id),
  executed     BOOLEAN DEFAULT FALSE,
  notes        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- inventory_usage
CREATE TABLE inventory_usage (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  visit_id      UUID NOT NULL REFERENCES visits(id),
  inventory_id  UUID NOT NULL REFERENCES inventory(id),
  quantity_used NUMERIC(10,3) NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- clinical_records
CREATE TABLE clinical_records (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  visit_id       UUID NOT NULL UNIQUE REFERENCES visits(id),
  animal_id      UUID NOT NULL REFERENCES animals(id),
  lead_id        UUID REFERENCES leads(id),
  weight_kg      NUMERIC(5,2),
  temperature_c  NUMERIC(4,1),
  diagnosis      TEXT,
  treatment      TEXT,
  prescriptions  TEXT,
  observations   TEXT,
  next_visit_rec TEXT,
  created_by     UUID REFERENCES users(id),
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  updated_at     TIMESTAMPTZ DEFAULT NOW()
);

-- audit_log
CREATE TABLE audit_log (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID REFERENCES users(id),
  entity     TEXT NOT NULL,
  entity_id  UUID NOT NULL,
  action     TEXT NOT NULL,
  payload    JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar RLS en todas las tablas
ALTER TABLE users              ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients            ENABLE ROW LEVEL SECURITY;
ALTER TABLE animals            ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads              ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE visits             ENABLE ROW LEVEL SECURITY;
ALTER TABLE procedures         ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory          ENABLE ROW LEVEL SECURITY;
ALTER TABLE procedure_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE visit_procedures   ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_usage    ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinical_records   ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log          ENABLE ROW LEVEL SECURITY;
