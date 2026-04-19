-- VetDesk — Agregar RUT a la tabla clients
-- El RUT se almacena normalizado: solo dígitos + dv en minúscula (sin puntos ni guión)
-- Ejemplo: "123456789" corresponde a 12.345.678-9

ALTER TABLE clients ADD COLUMN IF NOT EXISTS rut TEXT;

-- Índice único parcial: solo aplica cuando el RUT no es null
CREATE UNIQUE INDEX IF NOT EXISTS clients_rut_unique
  ON clients (rut) WHERE rut IS NOT NULL;
