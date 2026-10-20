-- Konfiguration: ein Fahrzeug, feste Werte (MVP)
CREATE TABLE IF NOT EXISTS config (
    key         TEXT PRIMARY KEY,
    value       TEXT NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Wetter-Messungen (vom Wetter-Logger)
CREATE TABLE IF NOT EXISTS weather_log (
    id            BIGSERIAL PRIMARY KEY,
    location_name TEXT NOT NULL,
    latitude      NUMERIC(8,5) NOT NULL,
    longitude     NUMERIC(8,5) NOT NULL,
    observed_at   TIMESTAMPTZ NOT NULL,
    temperature_c NUMERIC(4,1),
    precipitation_mm NUMERIC(5,2),
    snowfall_cm   NUMERIC(5,2),
    wind_speed_kmh NUMERIC(5,1),
    weather_code  INTEGER,
    fetched_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (location_name, observed_at)
);

-- Beispielwerte für das Auto (später anpassen)
INSERT INTO config (key, value) VALUES
    ('fuel_type', 'E10'),
    ('consumption_l_per_100km', '7.0')
ON CONFLICT (key) DO NOTHING;
