-- VetDesk — Migration 005: Mi Mascota Portal
-- Adds RUT to clients, preferred scheduling to leads, working hours and availability slots

-- 1. Agregar rut a clients (nullable — clientes existentes no tienen rut aún)
ALTER TABLE clients ADD COLUMN rut TEXT;

-- 2. Agregar preferred_date + preferred_time_slot a leads
ALTER TABLE leads
  ADD COLUMN preferred_date DATE,
  ADD COLUMN preferred_time_slot TEXT CHECK (preferred_time_slot IN ('maniana','tarde','noche'));

-- 3. Tabla de horarios de trabajo del técnico
CREATE TABLE working_hours (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id),
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Domingo
  start_time  TIME NOT NULL,
  end_time    TIME NOT NULL,
  active      BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, day_of_week)
);

-- 4. Tabla de slots disponibles por día (pre-calculados)
CREATE TABLE available_slots (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id),
  date        DATE NOT NULL,
  time_slot   TEXT NOT NULL CHECK (time_slot IN ('maniana','tarde','noche')),
  is_available BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date, time_slot)
);

-- 5. RUT validation helper (función SQL)
CREATE OR REPLACE FUNCTION validate_rut(rut TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  rut_clean TEXT;
  rut_num TEXT;
  dv CHAR(1);
  dv_calc CHAR(1);
  sum_val INTEGER := 0;
  mul INTEGER := 2;
  i INTEGER;
BEGIN
  IF rut IS NULL OR length(rut) < 2 THEN RETURN FALSE; END IF;
  rut_clean := regexp_replace(rut, '[^0-9kK]', '', 'g');
  IF length(rut_clean) < 2 THEN RETURN FALSE; END IF;
  rut_num := substring(rut_clean, 1, length(rut_clean) - 1);
  dv := lower(substring(rut_clean, length(rut_clean), 1));
  IF NOT (dv ~ '^[0-9k]$') THEN RETURN FALSE; END IF;
  FOR i IN REVERSE generate_series(length(rut_num), 1, -1) LOOP
    sum_val := sum_val + (substring(rut_num, i, 1)::INTEGER * mul);
    mul := mul + 1;
    IF mul > 7 THEN mul := 2; END IF;
  END LOOP;
  dv_calc := (11 - (sum_val % 11))::TEXT;
  IF dv_calc = '11' THEN dv_calc := '0';
  ELSIF dv_calc = '10' THEN dv_calc := 'k';
  END IF;
  RETURN dv_calc = dv;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
