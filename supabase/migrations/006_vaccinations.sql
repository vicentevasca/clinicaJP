-- VetDesk — Tabla de vacunas por animal
-- Ejecutar DESPUÉS de 001_initial_schema.sql y 002_rls_policies.sql

CREATE TABLE vaccinations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  animal_id       UUID NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
  visit_id        UUID REFERENCES visits(id) ON DELETE SET NULL,
  vaccine_name    TEXT NOT NULL,
  batch_number    TEXT,
  lab_name        TEXT,
  dose_number     INTEGER DEFAULT 1,
  administered_at DATE NOT NULL DEFAULT CURRENT_DATE,
  next_due_date   DATE,
  notes           TEXT,
  created_by      UUID REFERENCES users(id),
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE vaccinations ENABLE ROW LEVEL SECURITY;

CREATE INDEX idx_vaccinations_animal_id ON vaccinations(animal_id);
CREATE INDEX idx_vaccinations_visit_id  ON vaccinations(visit_id);
CREATE INDEX idx_vaccinations_next_due  ON vaccinations(next_due_date) WHERE next_due_date IS NOT NULL;

-- Todos los usuarios autenticados pueden leer
CREATE POLICY "vaccinations_select" ON vaccinations FOR SELECT
  USING (auth.role() = 'authenticated');

-- Admin y técnico pueden registrar vacunas
CREATE POLICY "vaccinations_insert" ON vaccinations FOR INSERT
  WITH CHECK (get_user_role() IN ('admin', 'tecnico'));

-- Admin y técnico pueden editar
CREATE POLICY "vaccinations_update" ON vaccinations FOR UPDATE
  USING (get_user_role() IN ('admin', 'tecnico'));

-- Solo admin puede eliminar
CREATE POLICY "vaccinations_delete" ON vaccinations FOR DELETE
  USING (get_user_role() = 'admin');

-- Trigger updated_at
CREATE TRIGGER vaccinations_updated_at
  BEFORE UPDATE ON vaccinations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
