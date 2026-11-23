# Tarea 6: Arquitectura Híbrida, Big Data e IoT

**Institución Universitaria Pascual Bravo**  
**Programa:** Tecnología en Desarrollo de Software  
**Asignatura:** Bases de Datos I  
**Grupo:** G100  
**Estudiante:** Alexandra Zapata  
**Docente:** Oralia Cortes Grajales  
**SGBD:** PostgreSQL (pgAdmin 4)

## 📖 Descripción del Proyecto
Este repositorio contiene la evolución de la base de datos relacional de la Red Social Pascualina hacia una **arquitectura híbrida**. Se integran datos semiestructurados (JSONB) para preferencias de usuario y metadatos de publicaciones, junto con una tabla optimizada para la ingesta masiva de datos de sensores (IoT), demostrando la aplicación de conceptos de Big Data en PostgreSQL.



## 🚀 Conceptos Aplicados
- Uso del tipo de dato `JSONB` para flexibilidad NoSQL.
- Creación de Índices **GIN** para optimización de búsquedas en JSON (Big Data).
- Consultas híbridas (JOIN entre tablas relacionales y campos JSON).
- Modelado de tabla IoT (`sensor_campus_iot`) con `BIGSERIAL` para alto volumen.

