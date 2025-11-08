# Introduction to n8n and database workflow

Este README te guía paso a paso para integrar n8n con bases de datos tradicionales (PostgreSQL, MySQL), Airtable (no-SQL tipo hoja de cálculo con API) y Supabase (Postgres gestionado con APIs listas). Está pensado para principiantes: sin vueltas, con ejemplos claros y listos para copiar/pegar.

## Bases de datos 101 

- Relacionales (PostgreSQL/MySQL): tablas/filas/columnas, SQL (SELECT/INSERT/UPDATE), ACID, claves, índices.

- Airtable: tablas “tipo sheet” con adjuntos, API + `filterByFormula` (no es SQL).

- Supabase: PostgreSQL gestionado + PostgREST (API REST automáticamente sobre tus tablas) + Auth/Storage.


## Supabase

1) Crear cuenta y proyecto en [Supabase](https://supabase.com/)
    - Regístrate en Supabase y haz New project.
    - Elige Project name, Region y define la Database password (guárdala).
    - Espera a que el proyecto quede Ready.
2) Obtener credenciales API
    - Ve a Project Settings → API y anota:
    - Project URL (base REST, termina en .supabase.co)
    - anon key (para clientes públicos, lectura con RLS)
    - service_role key (servidor/confianza; no la expongas en frontends)
Para conexión SQL (nodo Postgres / clientes):
    - Settings → Database → Connection info: host, puerto, user postgres, DB postgres, SSL required.

3) Crear tabla contacts (SQL Editor)
    - Abre SQL Editor en la página de proyecto.
    - Copia y corre este script (schema + índices):

```sql
-- contacts
CREATE TABLE IF NOT EXISTS contacts (
  contact_id       SERIAL PRIMARY KEY,
  first_name       TEXT NOT NULL,
  last_name        TEXT NOT NULL,
  name             TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
  email            TEXT NOT NULL UNIQUE,
  phone            TEXT,
  city             TEXT,
  province         TEXT,
  country          TEXT DEFAULT 'Argentina',
  status           TEXT CHECK (status IN ('Lead','Active','Churned','VIP')) NOT NULL,
  plan             TEXT CHECK (plan IN ('Bronze','Silver','Gold','Platinum')) NOT NULL,
  total_spent_usd  NUMERIC(12,2) DEFAULT 0,
  lifetime_orders  INT DEFAULT 0,
  preferred_channel TEXT,
  opt_in_email     BOOLEAN DEFAULT TRUE,
  opt_in_sms       BOOLEAN DEFAULT FALSE,
  signup_date      DATE NOT NULL,
  birthdate        DATE
);

CREATE INDEX IF NOT EXISTS idx_contacts_city ON contacts(city);
CREATE INDEX IF NOT EXISTS idx_contacts_status ON contacts(status);
CREATE INDEX IF NOT EXISTS idx_contacts_plan ON contacts(plan);
CREATE UNIQUE INDEX IF NOT EXISTS idx_contacts_email_lower ON contacts((lower(email)));

```

4) Inserta data en la table recién creada:

```sql
-- PostgreSQL insert script for dummy CRM contacts
BEGIN;
INSERT INTO contacts (first_name, last_name, email, phone, city, province, country, status, plan, total_spent_usd, lifetime_orders, preferred_channel, opt_in_email, opt_in_sms, signup_date, birthdate)
VALUES
('Joaquín', 'Rodríguez', 'jrodriguez@ejemplo.com', '+54 9 2901 2276-8040', 'Ushuaia', 'Tierra del Fuego', 'Argentina', 'Active', 'Bronze', 181.84, 2, 'SMS', TRUE, TRUE, '2022-06-14', '1979-12-16'),
('Sofía', 'Torres', 'storres@ejemplo.com', '+54 9 2964 4227-1333', 'Río Grande', 'Tierra del Fuego', 'Argentina', 'VIP', 'Gold', 1329.95, 16, 'WhatsApp', TRUE, TRUE, '2022-12-19', '1987-06-12'),
('Julián', 'Acosta', 'jacosta@ejemplo.com', '+54 9 2964 0679-8834', 'Río Grande', 'Tierra del Fuego', 'Argentina', 'Active', 'Bronze', 170.84, 1, 'WhatsApp', TRUE, TRUE, '2024-02-03', '1970-05-09'),
('Gonzalo', 'Castro', 'gcastro@ejemplo.com', '+54 9 342 4296-2370', 'Santa Fe', 'Santa Fe', 'Argentina', 'Churned', 'Gold', 2078.39, 33, 'WhatsApp', TRUE, TRUE, '2020-05-11', '1999-10-15'),
('Bruno', 'Farias', 'bfarias@ejemplo.com', '+54 9 341 2252-5832', 'Rosario', 'Santa Fe', 'Argentina', 'Churned', 'Silver', 232.98, 6, 'WhatsApp', FALSE, TRUE, '2021-07-20', '1992-11-15'),
('Leandro', 'López', 'llopez@ejemplo.com', '+54 9 387 3959-8076', 'Salta', 'Salta', 'Argentina', 'VIP', 'Gold', 1210.90, 31, 'Email', TRUE, FALSE, '2022-12-28', '1978-08-18'),
('Diego', 'Ruiz', 'druiz@ejemplo.com', '+54 9 376 9826-6175', 'Posadas', 'Misiones', 'Argentina', 'Lead', 'Silver', 454.09, 4, 'WhatsApp', TRUE, TRUE, '2020-01-03', '1976-08-10'),
('Julián', 'Martínez', 'jmartinez@ejemplo.com', '+54 9 223 7895-1691', 'Mar del Plata', 'Buenos Aires', 'Argentina', 'Active', 'Platinum', 7518.94, 91, 'SMS', TRUE, TRUE, '2024-09-29', '1988-07-02'),
('Renata', 'Aguilar', 'raguilar@ejemplo.com', '+54 9 388 1235-2206', 'San Salvador de Jujuy', 'Jujuy', 'Argentina', 'Churned', 'Bronze', 89.30, 1, 'Email', TRUE, TRUE, '2022-07-26', '2003-05-18'),
('Emma', 'Bravo', 'ebravo@ejemplo.com', '+54 9 297 4781-0444', 'Comodoro Rivadavia', 'Chubut', 'Argentina', 'Churned', 'Gold', 1363.67, 27, 'WhatsApp', TRUE, TRUE, '2020-08-09', '1972-01-24'),
('Gonzalo', 'Arias', 'garias@ejemplo.com', '+54 9 341 4229-4850', 'Rosario', 'Santa Fe', 'Argentina', 'Active', 'Platinum', 5885.13, 132, 'SMS', TRUE, TRUE, '2020-03-01', '1988-12-31'),
('Sofía', 'Peralta', 'speralta@ejemplo.com', '+54 9 266 9726-7764', 'San Luis', 'San Luis', 'Argentina', 'Active', 'Bronze', 140.13, 1, 'Email', TRUE, FALSE, '2022-02-16', '2000-02-11'),
('Florencia', 'Torres', 'ftorres@ejemplo.com', '+54 9 221 9015-6218', 'La Plata', 'Buenos Aires', 'Argentina', 'Churned', 'Silver', 257.39, 3, 'WhatsApp', TRUE, TRUE, '2022-10-05', '1978-05-24'),
('Tomás', 'Núñez', 'tnunez@ejemplo.com', '+54 9 264 2164-9906', 'San Juan', 'San Juan', 'Argentina', 'Churned', 'Bronze', 73.65, 1, 'WhatsApp', FALSE, TRUE, '2021-02-13', '1988-02-25'),
('Lucía', 'Torres', 'ltorres@ejemplo.com', '+54 9 388 8769-6082', 'San Salvador de Jujuy', 'Jujuy', 'Argentina', 'VIP', 'Platinum', 2923.43, 70, 'WhatsApp', TRUE, TRUE, '2021-02-28', '1973-11-23'),
('Nicolás', 'Silva', 'nsilva@ejemplo.com', '+54 9 2966 6249-8042', 'Río Gallegos', 'Santa Cruz', 'Argentina', 'Churned', 'Silver', 885.86, 21, 'SMS', TRUE, TRUE, '2020-01-15', '2005-04-27'),
('Sofía', 'Sánchez', 'ssanchez@ejemplo.com', '+54 9 223 9610-3540', 'Mar del Plata', 'Buenos Aires', 'Argentina', 'Churned', 'Gold', 2058.49, 42, 'Email', TRUE, TRUE, '2024-02-02', '2005-03-25'),
('Emilia', 'Vázquez', 'evazquez@ejemplo.com', '+54 9 2901 1989-8807', 'Ushuaia', 'Tierra del Fuego', 'Argentina', 'Active', 'Gold', 1829.08, 41, 'Email', TRUE, FALSE, '2023-09-22', '1989-04-27'),
('Valentina', 'Moreno', 'vmoreno@ejemplo.com', '+54 9 264 1938-8263', 'San Juan', 'San Juan', 'Argentina', 'Active', 'Gold', 1359.55, 9, 'WhatsApp', FALSE, TRUE, '2023-02-15', '1965-05-07'),
('Camila', 'Ruiz', 'cruiz@ejemplo.com', '+54 9 297 9214-7365', 'Comodoro Rivadavia', 'Chubut', 'Argentina', 'VIP', 'Gold', 862.14, 10, 'WhatsApp', FALSE, TRUE, '2024-04-26', '1972-09-04'),
('Martín', 'Navarro', 'mnavarro@ejemplo.com', '+54 9 223 9966-1956', 'Mar del Plata', 'Buenos Aires', 'Argentina', 'Active', 'Silver', 289.10, 5, 'Phone', TRUE, FALSE, '2023-08-29', '2006-01-21'),
('Franco', 'Vega', 'fvega@ejemplo.com', '+54 9 379 8327-6346', 'Corrientes', 'Corrientes', 'Argentina', 'Active', 'Gold', 1722.39, 33, 'WhatsApp', TRUE, TRUE, '2025-04-22', '1963-05-19'),
('Juan', 'Rojas', 'jrojas@ejemplo.com', '+54 9 264 8109-6748', 'San Juan', 'San Juan', 'Argentina', 'VIP', 'Gold', 1359.51, 39, 'WhatsApp', FALSE, TRUE, '2022-03-07', '1964-07-24'),
('Facundo', 'Molina', 'fmolina@ejemplo.com', '+54 9 342 8645-9114', 'Santa Fe', 'Santa Fe', 'Argentina', 'Active', 'Platinum', 7754.19, 86, 'WhatsApp', TRUE, TRUE, '2023-07-23', '1969-04-12'),
('Alejandro', 'Arias', 'aarias@ejemplo.com', '+54 9 266 7827-4247', 'San Luis', 'San Luis', 'Argentina', 'Active', 'Bronze', 43.21, 1, 'WhatsApp', TRUE, TRUE, '2022-08-18', '1960-10-05'),
('Emilia', 'Ponce', 'eponce@ejemplo.com', '+54 9 291 5424-9568', 'Bahía Blanca', 'Buenos Aires', 'Argentina', 'VIP', 'Silver', 409.03, 6, 'WhatsApp', FALSE, TRUE, '2024-04-07', '2003-04-15'),
('Gonzalo', 'Paredes', 'gparedes@ejemplo.com', '+54 9 11 2240-3641', 'Quilmes', 'Buenos Aires', 'Argentina', 'Active', 'Platinum', 9255.43, 95, 'WhatsApp', TRUE, TRUE, '2025-03-29', '1993-06-14'),
('Emma', 'Farias', 'efarias@ejemplo.com', '+54 9 342 0323-7378', 'Santa Fe', 'Santa Fe', 'Argentina', 'Lead', 'Gold', 2132.69, 52, 'Email', TRUE, FALSE, '2022-10-30', '1958-08-12'),
('Mateo', 'Castro', 'mcastro@ejemplo.com', '+54 9 261 8624-1942', 'Mendoza', 'Mendoza', 'Argentina', 'Active', 'Bronze', 189.50, 5, 'WhatsApp', FALSE, TRUE, '2024-02-19', '1964-09-12'),
('Karen', 'Rodríguez', 'krodriguez@ejemplo.com', '+54 9 11 3693-7066', 'Lomas de Zamora', 'Buenos Aires', 'Argentina', 'VIP', 'Gold', 1757.96, 16, 'WhatsApp', TRUE, TRUE, '2021-02-21', '1958-09-07'),
('Juana', 'Luna', 'jluna@ejemplo.com', '+54 9 381 6060-4443', 'San Miguel de Tucumán', 'Tucumán', 'Argentina', 'Active', 'Gold', 2151.66, 40, 'WhatsApp', TRUE, TRUE, '2025-02-26', '1998-05-18'),
('Bautista', 'Navarro', 'bnavarro@ejemplo.com', '+54 9 2284 7288-0824', 'Olavarría', 'Buenos Aires', 'Argentina', 'Active', 'Silver', 427.51, 7, 'SMS', TRUE, TRUE, '2024-04-01', '1980-02-02'),
('Leandro', 'Suárez', 'lsuarez@ejemplo.com', '+54 9 379 0907-4766', 'Corrientes', 'Corrientes', 'Argentina', 'Lead', 'Silver', 405.96, 5, 'Email', TRUE, FALSE, '2025-07-03', '1988-02-09'),
('Alejandro', 'Rey', 'arey@ejemplo.com', '+54 9 376 3953-4327', 'Posadas', 'Misiones', 'Argentina', 'Active', 'Bronze', 192.93, 3, 'Email', TRUE, TRUE, '2023-07-16', '2007-11-23'),
('Florencia', 'Paredes', 'fparedes@ejemplo.com', '+54 9 299 9823-3710', 'Neuquén', 'Neuquén', 'Argentina', 'Lead', 'Silver', 807.92, 12, 'WhatsApp', TRUE, TRUE, '2020-08-11', '1997-02-10'),
('Alejandro', 'Arias', 'aarias1@ejemplo.com', '+54 9 291 1094-8406', 'Bahía Blanca', 'Buenos Aires', 'Argentina', 'VIP', 'Bronze', 30.44, 1, 'WhatsApp', TRUE, TRUE, '2020-08-07', '1975-04-01'),
('Florencia', 'Peralta', 'fperalta@ejemplo.com', '+54 9 388 9254-5090', 'San Salvador de Jujuy', 'Jujuy', 'Argentina', 'Lead', 'Silver', 367.91, 4, 'Email', TRUE, TRUE, '2022-05-01', '1997-02-27'),
('Lucía', 'Gómez', 'lgomez@ejemplo.com', '+54 9 264 2280-2275', 'San Juan', 'San Juan', 'Argentina', 'Active', 'Silver', 835.89, 5, 'Email', TRUE, TRUE, '2022-03-21', '1982-08-06'),
('Leandro', 'Bravo', 'lbravo@ejemplo.com', '+54 9 11 2166-9540', 'Lomas de Zamora', 'Buenos Aires', 'Argentina', 'Lead', 'Gold', 1120.49, 9, 'WhatsApp', TRUE, TRUE, '2020-06-12', '1956-11-10'),
('Agustín', 'Bravo', 'abravo@ejemplo.com', '+54 9 221 7154-2948', 'La Plata', 'Buenos Aires', 'Argentina', 'Active', 'Silver', 273.22, 7, 'SMS', TRUE, TRUE, '2021-01-08', '1990-12-05'),
('Iván', 'Gómez', 'igomez@ejemplo.com', '+54 9 388 0217-8808', 'San Salvador de Jujuy', 'Jujuy', 'Argentina', 'Active', 'Silver', 453.25, 4, 'WhatsApp', FALSE, TRUE, '2025-03-07', '1973-04-06'),
('Agustín', 'Rey', 'arey1@ejemplo.com', '+54 9 341 9461-9621', 'Rosario', 'Santa Fe', 'Argentina', 'Churned', 'Silver', 894.58, 8, 'WhatsApp', TRUE, TRUE, '2020-02-26', '1968-10-24'),
('Carolina', 'Herrera', 'cherrera@ejemplo.com', '+54 9 376 7444-4115', 'Posadas', 'Misiones', 'Argentina', 'VIP', 'Gold', 1906.01, 29, 'Phone', TRUE, FALSE, '2021-07-13', '1980-05-17'),
('Franco', 'Godoy', 'fgodoy@ejemplo.com', '+54 9 297 9415-3554', 'Comodoro Rivadavia', 'Chubut', 'Argentina', 'Active', 'Gold', 1336.16, 11, 'SMS', TRUE, TRUE, '2023-08-11', '1997-06-07'),
('Malena', 'Peralta', 'mperalta@ejemplo.com', '+54 9 2966 7619-1931', 'Río Gallegos', 'Santa Cruz', 'Argentina', 'VIP', 'Bronze', 13.68, 1, 'WhatsApp', FALSE, TRUE, '2024-12-08', '1961-09-17'),
('Alejandro', 'Ortiz', 'aortiz@ejemplo.com', '+54 9 291 6303-6596', 'Bahía Blanca', 'Buenos Aires', 'Argentina', 'VIP', 'Gold', 895.79, 8, 'Phone', FALSE, FALSE, '2025-06-21', '1993-12-07'),
('Isabella', 'Pérez', 'iperez@ejemplo.com', '+54 9 388 1203-0342', 'San Salvador de Jujuy', 'Jujuy', 'Argentina', 'Active', 'Silver', 318.99, 10, 'WhatsApp', TRUE, TRUE, '2024-08-14', '1976-08-09'),
('Carolina', 'Godoy', 'cgodoy@ejemplo.com', '+54 9 341 2646-8425', 'Rosario', 'Santa Fe', 'Argentina', 'Active', 'Silver', 647.26, 11, 'Email', TRUE, FALSE, '2020-10-29', '1972-11-14'),
('Malena', 'Moreno', 'mmoreno@ejemplo.com', '+54 9 351 2559-2962', 'Córdoba', 'Córdoba', 'Argentina', 'VIP', 'Platinum', 8205.93, 199, 'WhatsApp', TRUE, TRUE, '2020-07-19', '1972-01-22'),
('Magdalena', 'Ortiz', 'mortiz@ejemplo.com', '+54 9 2966 7761-0607', 'Río Gallegos', 'Santa Cruz', 'Argentina', 'Lead', 'Silver', 406.58, 2, 'Email', TRUE, TRUE, '2020-05-16', '2003-05-24'),
('Martín', 'Aguilar', 'maguilar@ejemplo.com', '+54 9 376 9828-4873', 'Posadas', 'Misiones', 'Argentina', 'Churned', 'Silver', 727.91, 17, 'WhatsApp', TRUE, TRUE, '2021-04-16', '1990-08-27'),
('Iván', 'Méndez', 'imendez@ejemplo.com', '+54 9 223 7054-6658', 'Mar del Plata', 'Buenos Aires', 'Argentina', 'Active', 'Bronze', 16.01, 1, 'WhatsApp', FALSE, TRUE, '2024-03-01', '1974-11-10'),
('Martina', 'Farias', 'mfarias@ejemplo.com', '+54 9 11 7610-0912', 'Lomas de Zamora', 'Buenos Aires', 'Argentina', 'VIP', 'Silver', 687.54, 8, 'WhatsApp', TRUE, TRUE, '2021-07-09', '1992-03-21'),
('Isabella', 'Benítez', 'ibenitez@ejemplo.com', '+54 9 294 4903-4980', 'Bariloche', 'Río Negro', 'Argentina', 'VIP', 'Silver', 451.07, 7, 'Email', TRUE, TRUE, '2024-02-13', '1995-10-18'),
('Thiago', 'Silva', 'tsilva@ejemplo.com', '+54 9 280 6903-9728', 'Trelew', 'Chubut', 'Argentina', 'Active', 'Silver', 742.06, 8, 'WhatsApp', TRUE, TRUE, '2022-04-28', '1967-12-25'),
('Emma', 'Luna', 'eluna@ejemplo.com', '+54 9 266 7181-3750', 'San Luis', 'San Luis', 'Argentina', 'Active', 'Bronze', 188.96, 2, 'WhatsApp', TRUE, TRUE, '2022-12-22', '1964-10-13'),
('Renata', 'Campos', 'rcampos@ejemplo.com', '+54 9 264 9078-5490', 'San Juan', 'San Juan', 'Argentina', 'Lead', 'Gold', 1797.36, 23, 'WhatsApp', TRUE, TRUE, '2025-05-15', '1968-04-22'),
('Martina', 'Romero', 'mromero@ejemplo.com', '+54 9 266 6573-5254', 'San Luis', 'San Luis', 'Argentina', 'Active', 'Gold', 1101.03, 15, 'Email', TRUE, TRUE, '2021-04-13', '1995-09-08'),
('Bruno', 'Ponce', 'bponce@ejemplo.com', '+54 9 2901 0463-1908', 'Ushuaia', 'Tierra del Fuego', 'Argentina', 'Active', 'Silver', 291.08, 11, 'Phone', TRUE, FALSE, '2021-01-16', '1991-11-09'),
('Juana', 'Navarro', 'jnavarro@ejemplo.com', '+54 9 220 9023-1514', 'Merlo', 'Buenos Aires', 'Argentina', 'Lead', 'Silver', 395.00, 10, 'SMS', TRUE, TRUE, '2021-03-19', '2004-12-12'),
('Mateo', 'Paredes', 'mparedes@ejemplo.com', '+54 9 11 6602-7931', 'Lomas de Zamora', 'Buenos Aires', 'Argentina', 'Lead', 'Silver', 643.22, 25, 'WhatsApp', TRUE, TRUE, '2021-08-09', '1992-08-31'),
('Bautista', 'Cabrera', 'bcabrera@ejemplo.com', '+54 9 342 3775-0016', 'Santa Fe', 'Santa Fe', 'Argentina', 'Active', 'Bronze', 116.09, 1, 'WhatsApp', TRUE, TRUE, '2020-11-30', '1993-07-27'),
('Joaquín', 'Herrera', 'jherrera@ejemplo.com', '+54 9 2966 6460-3503', 'Río Gallegos', 'Santa Cruz', 'Argentina', 'Lead', 'Gold', 1496.34, 19, 'Email', TRUE, TRUE, '2022-05-15', '1975-08-24'),
('Diego', 'Rey', 'drey@ejemplo.com', '+54 9 2284 6337-4403', 'Olavarría', 'Buenos Aires', 'Argentina', 'Active', 'Silver', 492.39, 12, 'Email', TRUE, TRUE, '2024-10-24', '1996-04-11'),
('Martín', 'Martínez', 'mmartinez@ejemplo.com', '+54 9 381 8255-3333', 'San Miguel de Tucumán', 'Tucumán', 'Argentina', 'Active', 'Bronze', 56.54, 1, 'SMS', FALSE, TRUE, '2021-11-19', '1968-04-01'),
('Juan', 'Pérez', 'jperez@ejemplo.com', '+54 9 341 2117-0964', 'Rosario', 'Santa Fe', 'Argentina', 'Active', 'Gold', 2181.14, 49, 'Phone', TRUE, TRUE, '2025-01-12', '1997-01-25'),
('Renata', 'Rojas', 'rrojas@ejemplo.com', '+54 9 249 2053-4080', 'Tandil', 'Buenos Aires', 'Argentina', 'Active', 'Silver', 588.02, 4, 'WhatsApp', TRUE, TRUE, '2021-01-04', '2006-04-15'),
('Lola', 'Núñez', 'lnunez@ejemplo.com', '+54 9 294 4101-8375', 'Bariloche', 'Río Negro', 'Argentina', 'VIP', 'Bronze', 135.78, 2, 'SMS', FALSE, TRUE, '2021-12-07', '1989-10-03'),
('Emilia', 'Cabrera', 'ecabrera@ejemplo.com', '+54 9 2966 5760-0627', 'Río Gallegos', 'Santa Cruz', 'Argentina', 'Lead', 'Silver', 444.87, 3, 'WhatsApp', TRUE, TRUE, '2021-09-07', '1962-08-08'),
('Franco', 'Rey', 'frey@ejemplo.com', '+54 9 387 6317-9990', 'Salta', 'Salta', 'Argentina', 'Lead', 'Silver', 416.21, 2, 'Email', TRUE, FALSE, '2024-09-30', '1972-03-23'),
('Mía', 'Romero', 'mromero1@ejemplo.com', '+54 9 341 0817-8803', 'Rosario', 'Santa Fe', 'Argentina', 'Churned', 'Silver', 326.59, 3, 'WhatsApp', FALSE, TRUE, '2021-06-20', '1994-04-07'),
('Valentina', 'Ponce', 'vponce@ejemplo.com', '+54 9 343 6242-7453', 'Paraná', 'Entre Ríos', 'Argentina', 'VIP', 'Platinum', 7426.45, 118, 'SMS', FALSE, TRUE, '2025-04-05', '1989-04-05'),
('Diego', 'Aguilar', 'daguilar@ejemplo.com', '+54 9 381 9881-2685', 'San Miguel de Tucumán', 'Tucumán', 'Argentina', 'Churned', 'Gold', 917.43, 24, 'SMS', TRUE, TRUE, '2021-02-24', '1994-04-01'),
('Thiago', 'Molina', 'tmolina@ejemplo.com', '+54 9 2284 4300-5293', 'Olavarría', 'Buenos Aires', 'Argentina', 'Churned', 'Silver', 700.29, 16, 'Email', TRUE, TRUE, '2020-04-25', '1997-05-21'),
('Emma', 'Moreno', 'emoreno@ejemplo.com', '+54 9 388 6902-1964', 'San Salvador de Jujuy', 'Jujuy', 'Argentina', 'Lead', 'Bronze', 67.23, 1, 'WhatsApp', TRUE, TRUE, '2023-03-26', '1999-11-04'),
('Leandro', 'Luna', 'lluna@ejemplo.com', '+54 9 11 6572-0351', 'Buenos Aires', 'Buenos Aires', 'Argentina', 'VIP', 'Silver', 580.86, 5, 'WhatsApp', TRUE, TRUE, '2020-12-16', '1997-03-06'),
('Valentina', 'Peralta', 'vperalta@ejemplo.com', '+54 9 343 2073-7677', 'Paraná', 'Entre Ríos', 'Argentina', 'Active', 'Bronze', 91.25, 1, 'WhatsApp', TRUE, TRUE, '2023-09-23', '1997-12-06'),
('Lucas', 'Romero', 'lromero@ejemplo.com', '+54 9 223 7902-7833', 'Mar del Plata', 'Buenos Aires', 'Argentina', 'Active', 'Platinum', 8026.33, 195, 'SMS', FALSE, TRUE, '2024-06-19', '1984-10-11'),
('Agustín', 'Sánchez', 'asanchez@ejemplo.com', '+54 9 249 3878-3944', 'Tandil', 'Buenos Aires', 'Argentina', 'Churned', 'Gold', 1643.43, 16, 'WhatsApp', TRUE, TRUE, '2022-12-28', '1962-03-08'),
('Felicitas', 'Herrera', 'fherrera@ejemplo.com', '+54 9 299 4714-4796', 'Neuquén', 'Neuquén', 'Argentina', 'VIP', 'Bronze', 237.50, 5, 'WhatsApp', TRUE, TRUE, '2024-11-16', '1969-05-09'),
('Mateo', 'Álvarez', 'malvarez@ejemplo.com', '+54 9 220 6700-7335', 'Merlo', 'Buenos Aires', 'Argentina', 'Active', 'Gold', 1603.49, 20, 'SMS', TRUE, TRUE, '2021-09-20', '1977-05-24'),
('Joaquín', 'Rodríguez', 'jrodriguez1@ejemplo.com', '+54 9 2901 1591-7726', 'Ushuaia', 'Tierra del Fuego', 'Argentina', 'Lead', 'Bronze', 27.77, 1, 'WhatsApp', FALSE, TRUE, '2025-07-04', '1983-09-03'),
('Juana', 'López', 'jlopez@ejemplo.com', '+54 9 379 5887-9675', 'Corrientes', 'Corrientes', 'Argentina', 'Churned', 'Platinum', 5952.18, 129, 'WhatsApp', TRUE, TRUE, '2021-05-12', '2004-06-28'),
('Emma', 'Vázquez', 'evazquez1@ejemplo.com', '+54 9 11 0397-5780', 'Quilmes', 'Buenos Aires', 'Argentina', 'Active', 'Silver', 676.08, 11, 'WhatsApp', FALSE, TRUE, '2023-07-22', '2007-09-25'),
('Lucas', 'Romero', 'lromero1@ejemplo.com', '+54 9 381 5885-3192', 'San Miguel de Tucumán', 'Tucumán', 'Argentina', 'VIP', 'Gold', 1689.08, 19, 'Email', TRUE, TRUE, '2023-03-09', '2002-11-11'),
('Thiago', 'Campos', 'tcampos@ejemplo.com', '+54 9 280 1916-7685', 'Trelew', 'Chubut', 'Argentina', 'Active', 'Bronze', 73.52, 1, 'WhatsApp', TRUE, TRUE, '2020-04-26', '1957-09-19'),
('Carolina', 'Luna', 'cluna@ejemplo.com', '+54 9 299 6328-4461', 'Neuquén', 'Neuquén', 'Argentina', 'Active', 'Silver', 624.66, 13, 'WhatsApp', TRUE, TRUE, '2024-08-29', '1985-12-26'),
('Bruno', 'Romero', 'bromero@ejemplo.com', '+54 9 336 3534-2202', 'San Nicolás', 'Buenos Aires', 'Argentina', 'VIP', 'Gold', 2063.24, 20, 'Phone', TRUE, TRUE, '2024-04-22', '1969-04-18'),
('Carolina', 'Campos', 'ccampos@ejemplo.com', '+54 9 388 4309-5923', 'San Salvador de Jujuy', 'Jujuy', 'Argentina', 'Churned', 'Bronze', 171.40, 2, 'Email', TRUE, TRUE, '2020-07-26', '1967-01-06'),
('Camila', 'Méndez', 'cmendez@ejemplo.com', '+54 9 336 4005-3234', 'San Nicolás', 'Buenos Aires', 'Argentina', 'Lead', 'Gold', 935.35, 17, 'Phone', TRUE, TRUE, '2023-02-19', '1967-12-11'),
('Lola', 'Paredes', 'lparedes@ejemplo.com', '+54 9 376 4007-8518', 'Posadas', 'Misiones', 'Argentina', 'Active', 'Silver', 893.43, 9, 'Email', TRUE, TRUE, '2021-07-26', '2000-09-23'),
('Gonzalo', 'Benítez', 'gbenitez@ejemplo.com', '+54 9 2964 5403-1438', 'Río Grande', 'Tierra del Fuego', 'Argentina', 'Active', 'Silver', 880.44, 12, 'Email', TRUE, TRUE, '2020-04-19', '1998-02-07'),
('Catalina', 'Aguilar', 'caguilar@ejemplo.com', '+54 9 280 7738-2571', 'Trelew', 'Chubut', 'Argentina', 'Active', 'Silver', 683.35, 9, 'WhatsApp', FALSE, TRUE, '2024-12-11', '1960-08-02'),
('Emma', 'Aguilar', 'eaguilar@ejemplo.com', '+54 9 261 5943-9455', 'Mendoza', 'Mendoza', 'Argentina', 'Churned', 'Silver', 372.56, 3, 'Email', TRUE, FALSE, '2022-12-18', '1981-09-13'),
('Lucía', 'Silva', 'lsilva@ejemplo.com', '+54 9 2964 7339-7216', 'Río Grande', 'Tierra del Fuego', 'Argentina', 'VIP', 'Gold', 1283.19, 12, 'Email', TRUE, TRUE, '2024-04-04', '1962-02-02'),
('Juana', 'Arias', 'jarias@ejemplo.com', '+54 9 280 2425-9616', 'Trelew', 'Chubut', 'Argentina', 'Active', 'Bronze', 163.11, 4, 'SMS', TRUE, TRUE, '2022-09-07', '1964-01-08'),
('Emma', 'González', 'egonzalez@ejemplo.com', '+54 9 379 9168-4672', 'Corrientes', 'Corrientes', 'Argentina', 'Lead', 'Silver', 601.89, 8, 'WhatsApp', FALSE, TRUE, '2023-03-15', '1970-09-15'),
('Emilia', 'Ruiz', 'eruiz@ejemplo.com', '+54 9 11 9934-9998', 'Lomas de Zamora', 'Buenos Aires', 'Argentina', 'VIP', 'Bronze', 90.41, 1, 'WhatsApp', TRUE, TRUE, '2020-02-07', '1967-01-15'),
('Diego', 'Farias', 'dfarias@ejemplo.com', '+54 9 266 1114-2177', 'San Luis', 'San Luis', 'Argentina', 'Churned', 'Bronze', 208.48, 2, 'Email', TRUE, FALSE, '2022-03-02', '1971-07-30'),
('Emma', 'Moreno', 'emoreno1@ejemplo.com', '+54 9 291 9034-2355', 'Bahía Blanca', 'Buenos Aires', 'Argentina', 'Churned', 'Gold', 965.51, 18, 'SMS', TRUE, TRUE, '2022-12-07', '1982-11-25'),
('Joaquín', 'Herrera', 'jherrera1@ejemplo.com', '+54 9 343 6211-7645', 'Paraná', 'Entre Ríos', 'Argentina', 'Churned', 'Gold', 1866.60, 16, 'WhatsApp', FALSE, TRUE, '2025-04-12', '2002-02-22'),
('Renata', 'Aguilar', 'raguilar1@ejemplo.com', '+54 9 2964 3918-9251', 'Río Grande', 'Tierra del Fuego', 'Argentina', 'Active', 'Bronze', 149.96, 4, 'WhatsApp', FALSE, TRUE, '2024-12-14', '1995-09-06'),
('Emma', 'Campos', 'ecampos@ejemplo.com', '+54 9 381 4048-7387', 'San Miguel de Tucumán', 'Tucumán', 'Argentina', 'Lead', 'Bronze', 248.59, 1, 'Email', TRUE, FALSE, '2020-10-26', '1957-11-05'),
('Lucía', 'Ponce', 'lponce@ejemplo.com', '+54 9 342 7796-4938', 'Santa Fe', 'Santa Fe', 'Argentina', 'Active', 'Silver', 663.25, 7, 'WhatsApp', TRUE, TRUE, '2024-03-26', '1971-01-05'),
('Gonzalo', 'Vega', 'gvega@ejemplo.com', '+54 9 376 1987-9474', 'Posadas', 'Misiones', 'Argentina', 'VIP', 'Gold', 1284.62, 26, 'Phone', TRUE, TRUE, '2024-04-02', '1992-08-11'),
('Magdalena', 'Rodríguez', 'mrodriguez@ejemplo.com', '+54 9 264 2105-7074', 'San Juan', 'San Juan', 'Argentina', 'Active', 'Silver', 298.09, 2, 'Email', TRUE, FALSE, '2022-08-17', '2006-09-07'),
('Felicitas', 'Bravo', 'fbravo@ejemplo.com', '+54 9 294 7828-9542', 'Bariloche', 'Río Negro', 'Argentina', 'Active', 'Silver', 880.60, 8, 'WhatsApp', FALSE, TRUE, '2021-12-18', '1983-08-06'),
('Emilia', 'Ponce', 'eponce1@ejemplo.com', '+54 9 341 2152-2814', 'Rosario', 'Santa Fe', 'Argentina', 'Active', 'Silver', 293.86, 6, 'Email', TRUE, FALSE, '2020-08-24', '1995-05-09'),
('Martín', 'Martínez', 'mmartinez1@ejemplo.com', '+54 9 379 7126-6817', 'Corrientes', 'Corrientes', 'Argentina', 'Active', 'Silver', 869.91, 41, 'Phone', FALSE, TRUE, '2022-06-07', '1997-12-19'),
('Juan', 'Paredes', 'jparedes@ejemplo.com', '+54 9 2964 2957-3532', 'Río Grande', 'Tierra del Fuego', 'Argentina', 'Churned', 'Silver', 705.69, 6, 'Email', TRUE, TRUE, '2025-07-29', '1983-01-27'),
('Emilia', 'Gómez', 'egomez@ejemplo.com', '+54 9 297 8705-5721', 'Comodoro Rivadavia', 'Chubut', 'Argentina', 'Active', 'Silver', 658.23, 4, 'Email', TRUE, FALSE, '2022-07-31', '1999-01-05'),
('Bautista', 'Torres', 'btorres@ejemplo.com', '+54 9 2901 7174-9560', 'Ushuaia', 'Tierra del Fuego', 'Argentina', 'VIP', 'Gold', 1945.19, 77, 'Email', TRUE, TRUE, '2020-05-18', '1975-10-06'),
('Martina', 'Álvarez', 'malvarez1@ejemplo.com', '+54 9 11 2406-9960', 'Buenos Aires', 'Buenos Aires', 'Argentina', 'Active', 'Bronze', 75.94, 1, 'Email', TRUE, FALSE, '2024-08-11', '1993-08-18'),
('Lucas', 'Pérez', 'lperez@ejemplo.com', '+54 9 11 0115-8233', 'Lomas de Zamora', 'Buenos Aires', 'Argentina', 'Active', 'Silver', 688.07, 17, 'WhatsApp', TRUE, TRUE, '2024-07-21', '1957-11-04'),
('Thiago', 'Vega', 'tvega@ejemplo.com', '+54 9 387 3467-0863', 'Salta', 'Salta', 'Argentina', 'Churned', 'Gold', 2061.78, 22, 'WhatsApp', TRUE, TRUE, '2021-01-25', '1961-09-02'),
('Agustín', 'Luna', 'aluna@ejemplo.com', '+54 9 297 6180-2188', 'Comodoro Rivadavia', 'Chubut', 'Argentina', 'Active', 'Bronze', 213.87, 2, 'WhatsApp', TRUE, TRUE, '2020-11-11', '1967-07-22'),
('Thiago', 'Campos', 'tcampos1@ejemplo.com', '+54 9 2901 9048-3793', 'Ushuaia', 'Tierra del Fuego', 'Argentina', 'Active', 'Bronze', 248.22, 2, 'SMS', FALSE, TRUE, '2023-08-29', '1993-09-28'),
('Lucas', 'Godoy', 'lgodoy@ejemplo.com', '+54 9 2966 3722-0237', 'Río Gallegos', 'Santa Cruz', 'Argentina', 'VIP', 'Gold', 949.17, 37, 'Email', TRUE, TRUE, '2021-09-23', '1979-03-15'),
('Isabella', 'Romero', 'iromero@ejemplo.com', '+54 9 223 1454-0305', 'Mar del Plata', 'Buenos Aires', 'Argentina', 'VIP', 'Gold', 1379.33, 16, 'WhatsApp', TRUE, TRUE, '2023-08-21', '1976-10-11'),
('Julián', 'Aguilar', 'jaguilar@ejemplo.com', '+54 9 342 6122-1122', 'Santa Fe', 'Santa Fe', 'Argentina', 'Active', 'Silver', 547.06, 6, 'WhatsApp', TRUE, TRUE, '2020-11-11', '1955-08-10'),
('Bruno', 'Cabrera', 'bcabrera1@ejemplo.com', '+54 9 2284 6833-8891', 'Olavarría', 'Buenos Aires', 'Argentina', 'Active', 'Silver', 535.31, 15, 'SMS', TRUE, TRUE, '2023-08-06', '1999-01-19'),
('Julián', 'Castro', 'jcastro@ejemplo.com', '+54 9 291 3831-5556', 'Bahía Blanca', 'Buenos Aires', 'Argentina', 'Active', 'Platinum', 4330.65, 41, 'WhatsApp', FALSE, TRUE, '2020-04-20', '1991-09-15'),
('Carolina', 'Romero', 'cromero@ejemplo.com', '+54 9 280 3214-3455', 'Trelew', 'Chubut', 'Argentina', 'Active', 'Silver', 451.67, 5, 'WhatsApp', TRUE, TRUE, '2024-09-09', '1962-08-16'),
('Isabella', 'Castro', 'icastro@ejemplo.com', '+54 9 2966 6165-6693', 'Río Gallegos', 'Santa Cruz', 'Argentina', 'Lead', 'Bronze', 63.28, 1, 'WhatsApp', TRUE, TRUE, '2024-10-29', '1974-10-30'),
('Renata', 'Méndez', 'rmendez@ejemplo.com', '+54 9 387 4661-9429', 'Salta', 'Salta', 'Argentina', 'Lead', 'Bronze', 84.85, 1, 'Email', TRUE, TRUE, '2020-12-17', '1997-09-19'),
('Isabella', 'Arias', 'iarias@ejemplo.com', '+54 9 2901 6338-1866', 'Ushuaia', 'Tierra del Fuego', 'Argentina', 'Active', 'Platinum', 4647.92, 98, 'WhatsApp', FALSE, TRUE, '2021-11-04', '1971-07-20'),
('Lucas', 'Navarro', 'lnavarro@ejemplo.com', '+54 9 387 0615-3727', 'Salta', 'Salta', 'Argentina', 'Active', 'Silver', 456.06, 9, 'Email', TRUE, FALSE, '2020-09-13', '1998-11-30'),
('Florencia', 'Núñez', 'fnunez@ejemplo.com', '+54 9 294 3313-4168', 'Bariloche', 'Río Negro', 'Argentina', 'VIP', 'Gold', 1134.00, 32, 'SMS', TRUE, TRUE, '2020-12-13', '1989-11-07'),
('Emilia', 'Paredes', 'eparedes@ejemplo.com', '+54 9 341 5445-9911', 'Rosario', 'Santa Fe', 'Argentina', 'Active', 'Bronze', 118.24, 4, 'SMS', TRUE, TRUE, '2023-03-29', '1967-04-01'),
('Lola', 'Peralta', 'lperalta@ejemplo.com', '+54 9 379 5464-8400', 'Corrientes', 'Corrientes', 'Argentina', 'Active', 'Bronze', 50.37, 1, 'WhatsApp', FALSE, TRUE, '2022-06-22', '2004-04-26'),
('Diego', 'Sánchez', 'dsanchez@ejemplo.com', '+54 9 297 1783-8075', 'Comodoro Rivadavia', 'Chubut', 'Argentina', 'Churned', 'Bronze', 190.32, 1, 'Phone', TRUE, TRUE, '2024-10-07', '1962-10-21'),
('Renata', 'Sánchez', 'rsanchez@ejemplo.com', '+54 9 336 8276-8646', 'San Nicolás', 'Buenos Aires', 'Argentina', 'Active', 'Gold', 1635.60, 44, 'Phone', TRUE, FALSE, '2022-04-26', '2001-02-24'),
('Isabella', 'Romero', 'iromero1@ejemplo.com', '+54 9 336 7998-1827', 'San Nicolás', 'Buenos Aires', 'Argentina', 'Active', 'Gold', 1176.20, 15, 'WhatsApp', TRUE, TRUE, '2022-10-10', '1963-05-09'),
('Bruno', 'Campos', 'bcampos@ejemplo.com', '+54 9 2901 2939-3077', 'Ushuaia', 'Tierra del Fuego', 'Argentina', 'Active', 'Silver', 795.07, 7, 'SMS', FALSE, TRUE, '2025-02-20', '1974-01-02'),
('Carolina', 'Suárez', 'csuarez@ejemplo.com', '+54 9 291 8355-4360', 'Bahía Blanca', 'Buenos Aires', 'Argentina', 'Lead', 'Silver', 850.60, 19, 'WhatsApp', FALSE, TRUE, '2021-02-11', '1993-05-19'),
('Lola', 'Romero', 'lromero2@ejemplo.com', '+54 9 11 6192-6239', 'Quilmes', 'Buenos Aires', 'Argentina', 'Active', 'Bronze', 191.26, 4, 'Email', TRUE, TRUE, '2021-11-08', '1974-02-23'),
('Alejandro', 'López', 'alopez@ejemplo.com', '+54 9 341 5540-3186', 'Rosario', 'Santa Fe', 'Argentina', 'Active', 'Bronze', 185.38, 5, 'Email', TRUE, FALSE, '2025-05-10', '1967-04-21'),
('Malena', 'Romero', 'mromero2@ejemplo.com', '+54 9 280 9150-6476', 'Trelew', 'Chubut', 'Argentina', 'Active', 'Platinum', 9172.74, 256, 'Email', TRUE, FALSE, '2021-09-12', '1986-07-16'),
('Facundo', 'Núñez', 'fnunez1@ejemplo.com', '+54 9 249 1205-6676', 'Tandil', 'Buenos Aires', 'Argentina', 'Active', 'Bronze', 55.28, 1, 'WhatsApp', FALSE, TRUE, '2023-05-20', '1976-06-21'),
('Carolina', 'Peralta', 'cperalta@ejemplo.com', '+54 9 351 2608-0333', 'Córdoba', 'Córdoba', 'Argentina', 'Active', 'Silver', 733.91, 4, 'WhatsApp', TRUE, TRUE, '2024-09-19', '1961-01-21'),
('Sofía', 'Ortiz', 'sortiz@ejemplo.com', '+54 9 261 0075-6547', 'Mendoza', 'Mendoza', 'Argentina', 'Active', 'Silver', 258.52, 9, 'Phone', FALSE, TRUE, '2020-12-03', '1984-04-24'),
('Bruno', 'Godoy', 'bgodoy@ejemplo.com', '+54 9 280 7663-4922', 'Trelew', 'Chubut', 'Argentina', 'Active', 'Bronze', 23.21, 2, 'WhatsApp', TRUE, TRUE, '2024-11-14', '1956-02-20'),
('Emma', 'González', 'egonzalez1@ejemplo.com', '+54 9 342 4358-2378', 'Santa Fe', 'Santa Fe', 'Argentina', 'VIP', 'Gold', 1929.95, 30, 'Email', TRUE, FALSE, '2021-04-28', '2006-09-25'),
('Martina', 'Benítez', 'mbenitez@ejemplo.com', '+54 9 388 5081-1786', 'San Salvador de Jujuy', 'Jujuy', 'Argentina', 'Lead', 'Bronze', 217.10, 4, 'WhatsApp', TRUE, TRUE, '2021-04-17', '1968-06-18'),
('Lucas', 'Gómez', 'lgomez1@ejemplo.com', '+54 9 379 8762-2938', 'Corrientes', 'Corrientes', 'Argentina', 'Active', 'Bronze', 22.64, 1, 'WhatsApp', TRUE, TRUE, '2024-03-07', '1990-12-20'),
('Martina', 'Farias', 'mfarias1@ejemplo.com', '+54 9 220 2835-0253', 'Merlo', 'Buenos Aires', 'Argentina', 'Active', 'Silver', 740.83, 20, 'Phone', FALSE, TRUE, '2022-09-20', '1955-07-28'),
('Emilia', 'Rodríguez', 'erodriguez@ejemplo.com', '+54 9 264 5660-3737', 'San Juan', 'San Juan', 'Argentina', 'Active', 'Bronze', 67.16, 1, 'Email', TRUE, FALSE, '2023-06-13', '1980-02-08'),
('Thiago', 'Gómez', 'tgomez@ejemplo.com', '+54 9 11 2848-4755', 'Lomas de Zamora', 'Buenos Aires', 'Argentina', 'Active', 'Bronze', 114.40, 1, 'Email', TRUE, TRUE, '2024-06-03', '1983-04-06'),
('Bruno', 'Núñez', 'bnunez@ejemplo.com', '+54 9 291 4291-7114', 'Bahía Blanca', 'Buenos Aires', 'Argentina', 'Active', 'Silver', 875.24, 22, 'Email', TRUE, TRUE, '2023-07-10', '1965-10-04'),
('Thiago', 'Torres', 'ttorres@ejemplo.com', '+54 9 249 6860-8302', 'Tandil', 'Buenos Aires', 'Argentina', 'Lead', 'Silver', 409.19, 4, 'Email', TRUE, FALSE, '2023-12-28', '1995-07-27')

ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  phone = EXCLUDED.phone,
  city = EXCLUDED.city,
  province = EXCLUDED.province,
  country = EXCLUDED.country,
  status = EXCLUDED.status,
  plan = EXCLUDED.plan,
  total_spent_usd = EXCLUDED.total_spent_usd,
  lifetime_orders = EXCLUDED.lifetime_orders,
  preferred_channel = EXCLUDED.preferred_channel,
  opt_in_email = EXCLUDED.opt_in_email,
  opt_in_sms = EXCLUDED.opt_in_sms,
  signup_date = EXCLUDED.signup_date,
  birthdate = EXCLUDED.birthdate;
COMMIT;


```

## Airtable

1) Crear cuenta en [Airtable](https://airtable.com/)

    - Regístrate en Airtable y entra al panel.

2) Crear una base (usa la plantilla “Product Catalog”)

    - Click Create a base → Start with a template → busca Product Catalog.
    - Asigna un nombre (ej. Furniture Catalog).
    - Abre la base y revisa las tablas; normalmente tendrás una tabla tipo Products (o similar).

> Tip: Anota exactamente los nombres de los campos. En Airtable cuentan mayúsculas/minúsculas y espacios (ej.: Unit cost, Total unit sold).

3) Ir al “Builder/Developer Hub”

    - Desde tu avatar (arriba a la derecha) → Developer Hub (a veces aparece como Builder Hub).
    - Sección Developers → Create new token.

4) Crear un Personal Access Token (PAT)

    - Dale un nombre (ej.: n8n-integration).
    - Scopes (permisos) necesarios:
        - data.records:read
        - data.records:write
        - schema.bases:read
    - Access (acceso):
        - Opción rápida: All Resources (todas las bases de tu workspace).
        - Opción mínima: Only selected bases y selecciona la base que creaste.
    - Guárdalo: el token se muestra una sola vez. Trata el PAT como secreto.


##  Configuración de workflow en n8n con Airtable

Guía rápida para crear un flujo en **n8n** que consulta una base de **Airtable** (catálogo de muebles).

## Requisitos
- Cuenta de Airtable y **API Key (Personal Access Token)** activa.
- Base y tabla existentes (por ejemplo, `Furniture`).
- Acceso a n8n (self-hosted o Cloud).

## Pasos

1. **Crea un flujo de trabajo nuevo**
2. **Agrega un disparador de chat**
3. **Agrega un Agente de IA**
4. **Adjunta un modelo** (p. ej., OpenAI)
5. **Agrega una memoria simple**
6. **Agrega un nodo de Airtable** con los siguientes parámetros:
   - **Credenciales:** agrega la clave (API Key) que obtuviste de Airtable
   - **Tool Description:** *se establece automáticamente*
   - **Resource:** `Record`
   - **Operation:** `Search`
   - **Base:** nombre de tu base
   - **Table:** `Furniture`
   - **Return All:** activar

---

### Notas
- Verifica que el token tenga permisos de **lectura** para la base/tabla seleccionada.
- Si la tabla usa nombres con espacios, respétalos exactamente (p. ej., `Unit cost`).


## n8n - Postgres

# Configuración de workflow en n8n con Postgres (Supabase)

Guía rápida para crear un flujo en **n8n** que valide una consulta SQL con IA y ejecute la query en **Supabase (Postgres)**.

## Requisitos
- Proyecto en Supabase (URL, `anon key` y/o credenciales de base de datos).
- Acceso a n8n (self-hosted o Cloud).
- Un modelo de IA disponible (p. ej., OpenAI).

## Pasos

1. **Agrega un disparador de chat**
2. **Agrega un Agente de IA** *(debes crear el **system message**)*  
3. **Agrega un modelo** (p. ej., OpenAI)
4. **Agrega una memoria simple**
5. **Conecta la salida al nodo “Basic LLM Chain”**.  
   Este nodo validará el SQL producido por el primer agente. *(debes crear el **system message** para la validación)*
6. **Agrega un modelo** al “Basic LLM Chain”
7. **Crea un nodo IF** para comprobar si la consulta SQL es válida
8. **Rama Válida** → conecta a un **nodo Postgres** con estos ajustes:
   - **Credentials:** tus credenciales de **Supabase**
   - **Operation:** `Execute Query`
   - **Query:** `{{ $json.text }}`
9. **Agrega otro nodo “Basic LLM Chain”** que tome la salida del nodo Postgres y devuelva el resultado en formato legible. *(debes crear el **system message**)*
10. **Agrega un modelo** a ese nodo “Basic LLM Chain”
11. **Rama Inválida del IF:** define un mensaje fijo o agrega otro “Basic LLM Chain” para devolver un error clara y amablemente.

---

### Notas
- Los **system messages** recomendados:
  - **Agente de IA (generación de SQL):** instruye a generar **solo** consultas `SELECT` (sin `INSERT/UPDATE/DELETE/DDL`), sobre las tablas permitidas, con filtros seguros, y devolver **únicamente** la sentencia SQL.
  - **Validador (LLM Chain):** verifica que la salida sea **solo SQL**, sin comentarios ni markdown, y que no contenga operaciones prohibidas. Si falla, marca como inválida.
  - **Formateador de resultados (LLM Chain final):** transforma las filas devueltas por Postgres en una respuesta breve (tabla/markdown o JSON si se solicita).
- En Supabase con nodo Postgres, activa **SSL** si tu instancia lo requiere.

---
[⬅ Back to Course Overview](../../README.md)
