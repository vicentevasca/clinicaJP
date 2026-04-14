-- RLS Policies para VetDesk
-- IMPORTANTE: Ejecutar DESPUÉS de 001_initial_schema.sql

-- Helper: obtener rol del usuario actual
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT AS $$
  SELECT role FROM users WHERE id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- === USERS ===
CREATE POLICY "users_select_own" ON users FOR SELECT
  USING (id = auth.uid() OR get_user_role() = 'admin');

CREATE POLICY "users_update_own" ON users FOR UPDATE
  USING (id = auth.uid());

-- === CLIENTS ===
CREATE POLICY "clients_all_authenticated" ON clients FOR ALL
  USING (auth.role() = 'authenticated');

-- === ANIMALS ===
CREATE POLICY "animals_all_authenticated" ON animals FOR ALL
  USING (auth.role() = 'authenticated');

-- === LEADS ===
CREATE POLICY "leads_select" ON leads FOR SELECT
  USING (get_user_role() = 'admin' OR assigned_to = auth.uid());

CREATE POLICY "leads_insert" ON leads FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "leads_update" ON leads FOR UPDATE
  USING (get_user_role() = 'admin' OR assigned_to = auth.uid());

-- === LEAD STATUS HISTORY ===
CREATE POLICY "lead_history_select" ON lead_status_history FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "lead_history_insert" ON lead_status_history FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- === VISITS ===
CREATE POLICY "visits_select" ON visits FOR SELECT
  USING (get_user_role() = 'admin' OR assigned_to = auth.uid());

CREATE POLICY "visits_insert_update" ON visits FOR ALL
  USING (get_user_role() IN ('admin', 'tecnico'));

-- === PROCEDURES ===
CREATE POLICY "procedures_read" ON procedures FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "procedures_write" ON procedures FOR ALL
  USING (get_user_role() = 'admin');

-- === INVENTORY ===
CREATE POLICY "inventory_read" ON inventory FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "inventory_write" ON inventory FOR ALL
  USING (get_user_role() = 'admin');

-- === CLINICAL RECORDS ===
CREATE POLICY "clinical_read" ON clinical_records FOR SELECT
  USING (
    get_user_role() = 'admin'
    OR EXISTS (
      SELECT 1 FROM visits v
      WHERE v.id = clinical_records.visit_id AND v.assigned_to = auth.uid()
    )
  );

CREATE POLICY "clinical_insert" ON clinical_records FOR INSERT
  WITH CHECK (get_user_role() IN ('admin', 'tecnico'));

-- === AUDIT LOG ===
CREATE POLICY "audit_read" ON audit_log FOR SELECT
  USING (get_user_role() = 'admin');

-- Solo Edge Functions (service_role) pueden insertar
CREATE POLICY "audit_insert_service" ON audit_log FOR INSERT
  WITH CHECK (get_user_role() IS NOT NULL);
