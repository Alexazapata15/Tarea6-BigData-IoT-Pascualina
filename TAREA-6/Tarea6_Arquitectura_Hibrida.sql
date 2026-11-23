-- =====================================================================
-- TAREA 6: ARQUITECTURA DE BASE DE DATOS HÍBRIDA (RELACIONAL + JSON + IOT)
-- SGBD: PostgreSQL
-- =====================================================================

-- Limpiar tablas anteriores si existen
DROP TABLE IF EXISTS sensor_campus_iot, reaccion, comentario, publicacion_estudiante, publicacion, seguir, mentoria, estudiante_evento, estudiante_grupo, estudiante_interes, estudiante_habilidad, interes, habilidad, evento, grupo, estudiante CASCADE;

-- 1. TABLAS RELACIONALES CON CAMPOS SEMIESTRUCTURADOS (JSONB)
CREATE TABLE estudiante (
    id_estudiante SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    programa VARCHAR(100),
    preferencias_json JSONB DEFAULT '{}'::jsonb 
);

CREATE TABLE grupo (
    id_grupo SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50)
);

CREATE TABLE evento (
    id_evento SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    fecha_hora TIMESTAMP,
    lugar VARCHAR(150)
);

CREATE TABLE publicacion (
    id_publicacion SERIAL PRIMARY KEY,
    contenido TEXT NOT NULL,
    tipo VARCHAR(50),
    metadatos_json JSONB DEFAULT '{}'::jsonb
);

CREATE TABLE habilidad (
    id_habilidad SERIAL PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE estudiante_habilidad (
    id_estudiante INT REFERENCES estudiante(id_estudiante),
    id_habilidad INT REFERENCES habilidad(id_habilidad),
    nivel VARCHAR(30),
    PRIMARY KEY (id_estudiante, id_habilidad)
);

CREATE TABLE seguir (
    id_seguidor INT REFERENCES estudiante(id_estudiante),
    id_seguido INT REFERENCES estudiante(id_estudiante),
    PRIMARY KEY (id_seguidor, id_seguido)
);

-- 2. NUEVA TABLA IOT (Alto volumen de datos)
CREATE TABLE sensor_campus_iot (
    id_lectura BIGSERIAL PRIMARY KEY, 
    id_sensor VARCHAR(50) NOT NULL,
    ubicacion VARCHAR(100) NOT NULL,
    tipo_sensor VARCHAR(50) NOT NULL, 
    datos_sensor JSONB NOT NULL, 
    fecha_lectura TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. ÍNDICES GIN (Fundamentales para Big Data y JSON)
CREATE INDEX idx_estudiante_preferencias ON estudiante USING GIN (preferencias_json);
CREATE INDEX idx_publicacion_metadatos ON publicacion USING GIN (metadatos_json);
CREATE INDEX idx_sensor_datos ON sensor_campus_iot USING GIN (datos_sensor);

-- 4. INSERCIÓN DE DATOS DE PRUEBA

INSERT INTO estudiante (nombre, email, programa, preferencias_json) VALUES 
('Ana Gómez', 'ana@pascualbravo.edu.co', 'Desarrollo de Software', '{"tema_oscuro": true, "idioma": "es", "notificaciones": {"email": true, "push": false}}'),
('Carlos Pérez', 'carlos@pascualbravo.edu.co', 'Ingeniería de Software', '{"tema_oscuro": false, "idioma": "en", "notificaciones": {"email": false, "push": true}}'),
('Luisa Martínez', 'luisa@pascualbravo.edu.co', 'Diseño Gráfico', '{"tema_oscuro": true, "idioma": "es", "notificaciones": {"email": true, "push": true}}');

INSERT INTO habilidad (nombre) VALUES ('Programación en Python'), ('Bases de Datos'), ('Diseño UX/UI');
INSERT INTO estudiante_habilidad VALUES (1, 1, 'avanzado'), (2, 2, 'avanzado'), (3, 3, 'intermedio');

INSERT INTO publicacion (contenido, tipo, metadatos_json) VALUES 
('Aprendiendo sobre índices GIN en Postgres', 'Texto', '{"hashtags": ["#basededatos", "#postgres", "#bigdata"], "etiquetas": ["tecnologia"]}'),
('Miren mi nuevo proyecto de diseño', 'Imagen', '{"hashtags": ["#ux", "#diseño"], "etiquetas": ["arte"], "imagen_url": "http://img.com/1.jpg", "resolucion": "1080x1080"}'),
('¿Alguien para estudiar IoT?', 'Texto', '{"hashtags": ["#iot", "#estudio"], "etiquetas": ["ayuda"]}');

INSERT INTO sensor_campus_iot (id_sensor, ubicacion, tipo_sensor, datos_sensor) VALUES 
('S-AULA-101', 'Bloque A, Aula 101', 'aforo', '{"estudiantes_presentes": 35, "capacidad_maxima": 40, "estado": "lleno"}'),
('S-AULA-101', 'Bloque A, Aula 101', 'temperatura', '{"grados_celsius": 24.5, "humedad": 60}'),
('S-BIBLIO-01', 'Biblioteca Central', 'acceso', '{"tarjeta_uid": "A1B2C3D4", "tipo_usuario": "estudiante", "puerta": "entrada_principal"}'),
('S-AULA-202', 'Bloque B, Aula 202', 'aforo', '{"estudiantes_presentes": 12, "capacidad_maxima": 30, "estado": "disponible"}');

INSERT INTO seguir (id_seguidor, id_seguido) VALUES (1, 2), (1, 3), (3, 1);

-- =====================================================================
-- CONSULTAS DML SOBRE DATOS SEMIESTRUCTURADOS (JSON)
-- =====================================================================

-- Consulta 1: Filtro JSON (Tema Oscuro)
SELECT nombre, email, 
       preferencias_json ->> 'idioma' AS idioma,
       preferencias_json -> 'notificaciones' ->> 'push' AS recibe_push
FROM estudiante
WHERE preferencias_json ->> 'tema_oscuro' = 'true';

-- Consulta 2: Extracción de Hashtags
SELECT id_publicacion, 
       contenido, 
       metadatos_json -> 'hashtags' AS lista_hashtags
FROM publicacion
WHERE tipo = 'Texto';

-- Consulta 3: Búsqueda Optimizada por Hashtag
SELECT contenido, tipo 
FROM publicacion
WHERE metadatos_json @> '{"hashtags": ["#bigdata"]}'::jsonb;

-- Consulta 4: Analítica de Sensores IoT
SELECT ubicacion, 
       datos_sensor ->> 'estado' AS estado_aula,
       (datos_sensor ->> 'estudiantes_presentes')::int AS presentes,
       (datos_sensor ->> 'capacidad_maxima')::int AS capacidad
FROM sensor_campus_iot
WHERE tipo_sensor = 'aforo'
  AND datos_sensor ->> 'estado' = 'lleno';

-- Consulta 5: Cruce Relacional + JSON
SELECT e1.nombre AS estudiante_sigue,
       e2.nombre AS seguido,
       e1.preferencias_json ->> 'idioma' AS idioma_preferido
FROM estudiante e1
JOIN seguir s ON e1.id_estudiante = s.id_seguidor
JOIN estudiante e2 ON s.id_seguido = e2.id_estudiante
WHERE e1.preferencias_json ->> 'tema_oscuro' = 'true';