USE conjunta3p_db;

-- =========================================================
-- 1) Hackathon
-- =========================================================
INSERT INTO Hackathon (codigo, nombre, fechaInicio, fechaFin, modalidad, lugar, estado)
VALUES
('eduhack2025', 'EduHack Sostenibilidad 2025', '2025-04-15 09:00:00', '2025-04-16 18:00:00', 'HIBRIDO', 'Plataforma online + sedes presenciales', 'EN_CURSO');

-- =========================================================
-- 2) Participantes (padre)
-- =========================================================
INSERT INTO Participante (codigo, tipo, nombre, email, nivelHabilidad, habilidades)
VALUES
('estudiante_001', 'ESTUDIANTE', 'Lucía Mendoza', 'lucia.mendoza@estudiante.edu', 'intermedio',
 JSON_ARRAY('JavaScript','UI/UX','Python')),
('estudiante_002', 'ESTUDIANTE', 'Juan Torres', 'juan.torres@estudiante.edu', 'basico',
 JSON_ARRAY('HTML','CSS','Diseño Gráfico')),
('mentor_005', 'MENTOR_TECNICO', 'Dr. Carlos Rivas', 'carlos.rivas@mentor.edu', 'avanzado',
 JSON_ARRAY('Inteligencia Artificial','Machine Learning','Data Science'));

-- =========================================================
-- 3) Estudiantes y Mentor Técnico (subtipos)
-- =========================================================
-- OJO: Los IDs se generan AUTO_INCREMENT, necesitamos saberlos
-- Aquí asumo que fueron generados en orden 1, 2, 3
INSERT INTO Estudiante (id, grado, institucion, tiempoDisponibleSemanal)
VALUES
(1, '11', 'Colegio Innovación Futuro', 20),
(2, '10', 'Colegio Creativo Global', 15);

INSERT INTO MentorTecnico (id, especialidad, experiencia, disponibilidadHoraria)
VALUES
(3, 'Inteligencia Artificial', 8, 'viernes y sábados');

-- =========================================================
-- 4) Retos (padre)
-- =========================================================
INSERT INTO Reto (codigo, hackathon_id, tipo, titulo, descripcion, complejidad, areasConocimiento, estado)
VALUES
('reto_101', 1, 'REAL', 'App para monitoreo de basureros ilegales',
 'Desarrollar una app móvil que permita reportar y geolocalizar basureros ilegales.',
 'dificil', JSON_ARRAY('Geolocalización','Mobile','Medioambiente'), 'ACTIVO'),
('reto_102', 1, 'EXPERIMENTAL', 'Simulador de ecosistemas con IA generativa',
 'Usar IA para modelar cómo cambia un ecosistema ante cambios climáticos.',
 'media', JSON_ARRAY('IA generativa','Ecología','Simulación'), 'ACTIVO');

-- =========================================================
-- 5) Subtipos de Retos
-- =========================================================
INSERT INTO RetoReal (id, entidadColaboradora)
VALUES
(1, 'GreenEarth ONG');

INSERT INTO RetoExperimental (id, enfoquePedagogico)
VALUES
(2, 'ABP (Aprendizaje Basado en Proyectos)');

-- =========================================================
-- 6) Equipos
-- =========================================================
INSERT INTO Equipo (codigo, nombre, hackathon_id)
VALUES
('equipo_501', 'EcoHackers', 1);

-- =========================================================
-- 7) EquipoParticipante (M:N)
-- =========================================================
INSERT INTO EquipoParticipante (equipo_id, participante_id, rol)
VALUES
(1, 1, 'ESTUDIANTE'),   -- Lucía
(1, 2, 'ESTUDIANTE'),   -- Juan
(1, 3, 'MENTOR_TECNICO'); -- Dr. Carlos

-- =========================================================
-- 8) EquipoReto (M:N con estado)
-- =========================================================
INSERT INTO EquipoReto (equipo_id, reto_id, estado, avance)
VALUES
(1, 1, 'en_progreso', 40),  -- App monitoreo basureros
(1, 2, 'en_progreso', 20);  -- Simulador IA generativa

-- =========================================================
-- 9) Otro equipo para ejemplo de "retos populares"
-- =========================================================
INSERT INTO Equipo (codigo, nombre, hackathon_id)
VALUES
('equipo_503', 'CodeVerde', 1);

-- Participantes ficticios para el segundo equipo
INSERT INTO Participante (codigo, tipo, nombre, email, nivelHabilidad, habilidades)
VALUES
('estudiante_003', 'ESTUDIANTE', 'María López', 'maria.lopez@estudiante.edu', 'intermedio',
 JSON_ARRAY('Python','Data Analysis')),
('mentor_006', 'MENTOR_TECNICO', 'Ing. Roberto Pérez', 'roberto.perez@mentor.edu', 'avanzado',
 JSON_ARRAY('Cloud Computing','IoT')) ;

INSERT INTO Estudiante (id, grado, institucion, tiempoDisponibleSemanal)
VALUES
(4, '12', 'Unidad Educativa Horizonte', 25);

INSERT INTO MentorTecnico (id, especialidad, experiencia, disponibilidadHoraria)
VALUES
(5, 'Internet de las Cosas', 5, 'fines de semana');

INSERT INTO EquipoParticipante (equipo_id, participante_id, rol)
VALUES
(2, 4, 'ESTUDIANTE'),
(2, 5, 'MENTOR_TECNICO');

-- Asignación de un reto al segundo equipo
INSERT INTO EquipoReto (equipo_id, reto_id, estado, avance)
VALUES
(2, 1, 'en_progreso', 10); -- App monitoreo basureros
