# Base de Datos EduHack - Diseño Table Per Type (TPT)

## 1. Tablas Base (Abstractas)

### Tabla: participantes (Base)

CREATE TABLE participantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo ENUM('estudiante', 'mentorTecnico') NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    nivel_habilidad ENUM('principiante', 'intermedio', 'avanzado') NOT NULL,
    habilidades JSON NOT NULL, -- Array de habilidades
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


### Tabla: retos (Base)

CREATE TABLE retos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo ENUM('retoReal', 'retoExperimental') NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    complejidad ENUM('facil', 'media', 'dificil') NOT NULL,
    areas_conocimiento JSON NOT NULL, -- Array de áreas
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


## 2. Tablas Específicas de Participantes

### Tabla: estudiantes

CREATE TABLE estudiantes (
    participante_id INT PRIMARY KEY,
    grado VARCHAR(10) NOT NULL,
    institucion VARCHAR(255) NOT NULL,
    tiempo_disponible_semanal INT NOT NULL,
    
    FOREIGN KEY (participante_id) REFERENCES participantes(id) ON DELETE CASCADE
);


### Tabla: mentores_tecnicos

CREATE TABLE mentores_tecnicos (
    participante_id INT PRIMARY KEY,
    especialidad VARCHAR(255) NOT NULL,
    experiencia_anos INT NOT NULL,
    disponibilidad_horaria VARCHAR(255) NOT NULL,
    
    FOREIGN KEY (participante_id) REFERENCES participantes(id) ON DELETE CASCADE
);


## 3. Tablas Específicas de Retos

### Tabla: retos_reales

CREATE TABLE retos_reales (
    reto_id INT PRIMARY KEY,
    entidad_colaboradora VARCHAR(255) NOT NULL,
    
    FOREIGN KEY (reto_id) REFERENCES retos(id) ON DELETE CASCADE
);


### Tabla: retos_experimentales

CREATE TABLE retos_experimentales (
    reto_id INT PRIMARY KEY,
    enfoque_pedagogico VARCHAR(255) NOT NULL,
    
    FOREIGN KEY (reto_id) REFERENCES retos(id) ON DELETE CASCADE
);


## 4. Tablas de Hackathons y Equipos

### Tabla: hackathons

CREATE TABLE hackathons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    lugar VARCHAR(255),
    estado ENUM('planificado', 'activo', 'finalizado') DEFAULT 'planificado',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


### Tabla: equipos

CREATE TABLE equipos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    hackathon_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (hackathon_id) REFERENCES hackathons(id) ON DELETE CASCADE
);


## 5. Tablas de Relación (Muchos a Muchos)

### Tabla: equipo_participantes

CREATE TABLE equipo_participantes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    equipo_id INT NOT NULL,
    participante_id INT NOT NULL,
    rol_en_equipo VARCHAR(100) NOT NULL, -- 'lider', 'desarrollador', 'mentor', etc.
    fecha_union TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE CASCADE,
    FOREIGN KEY (participante_id) REFERENCES participantes(id) ON DELETE CASCADE,
    UNIQUE KEY unique_equipo_participante (equipo_id, participante_id)
);


### Tabla: equipo_retos (Relación Muchos a Muchos Principal)

CREATE TABLE equipo_retos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    equipo_id INT NOT NULL,
    reto_id INT NOT NULL,
    estado ENUM('asignado', 'en_progreso', 'completado', 'abandonado') DEFAULT 'asignado',
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_completion TIMESTAMP NULL,
    progreso_porcentaje INT DEFAULT 0 CHECK (progreso_porcentaje BETWEEN 0 AND 100),
    notas TEXT,
    
    FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE CASCADE,
    FOREIGN KEY (reto_id) REFERENCES retos(id) ON DELETE CASCADE,
    UNIQUE KEY unique_equipo_reto (equipo_id, reto_id)
);


## 6. Triggers para Integridad de Herencia

### Trigger para validar tipo de participante

DELIMITER $$

CREATE TRIGGER validate_estudiante_insert
BEFORE INSERT ON estudiantes
FOR EACH ROW
BEGIN
    DECLARE participant_type VARCHAR(50);
    SELECT tipo INTO participant_type FROM participantes WHERE id = NEW.participante_id;
    IF participant_type != 'estudiante' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo participantes tipo estudiante pueden insertarse en tabla estudiantes';
    END IF;
END$$

CREATE TRIGGER validate_mentor_insert
BEFORE INSERT ON mentores_tecnicos
FOR EACH ROW
BEGIN
    DECLARE participant_type VARCHAR(50);
    SELECT tipo INTO participant_type FROM participantes WHERE id = NEW.participante_id;
    IF participant_type != 'mentorTecnico' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo participantes tipo mentorTecnico pueden insertarse en tabla mentores_tecnicos';
    END IF;
END$$

DELIMITER ;


### Trigger para validar tipo de reto

DELIMITER $$

CREATE TRIGGER validate_reto_real_insert
BEFORE INSERT ON retos_reales
FOR EACH ROW
BEGIN
    DECLARE challenge_type VARCHAR(50);
    SELECT tipo INTO challenge_type FROM retos WHERE id = NEW.reto_id;
    IF challenge_type != 'retoReal' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo retos tipo retoReal pueden insertarse en tabla retos_reales';
    END IF;
END$$

CREATE TRIGGER validate_reto_experimental_insert
BEFORE INSERT ON retos_experimentales
FOR EACH ROW
BEGIN
    DECLARE challenge_type VARCHAR(50);
    SELECT tipo INTO challenge_type FROM retos WHERE id = NEW.reto_id;
    IF challenge_type != 'retoExperimental' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo retos tipo retoExperimental pueden insertarse en tabla retos_experimentales';
    END IF;
END$$

DELIMITER ;

## 7. Índices para Optimización


CREATE INDEX idx_participantes_tipo ON participantes(tipo);
CREATE INDEX idx_participantes_email ON participantes(email);
CREATE INDEX idx_participantes_nivel ON participantes(nivel_habilidad);

CREATE INDEX idx_retos_tipo ON retos(tipo);
CREATE INDEX idx_retos_complejidad ON retos(complejidad);

-- Índices en tablas específicas
CREATE INDEX idx_estudiantes_grado ON estudiantes(grado);
CREATE INDEX idx_estudiantes_institucion ON estudiantes(institucion);
CREATE INDEX idx_mentores_especialidad ON mentores_tecnicos(especialidad);

-- Índices en relaciones
CREATE INDEX idx_equipo_participantes_equipo ON equipo_participantes(equipo_id);
CREATE INDEX idx_equipo_participantes_participante ON equipo_participantes(participante_id);
CREATE INDEX idx_equipo_retos_equipo ON equipo_retos(equipo_id);
CREATE INDEX idx_equipo_retos_reto ON equipo_retos(reto_id);
CREATE INDEX idx_equipo_retos_estado ON equipo_retos(estado);


-- =====================================================
-- PROCEDIMIENTOS CRUD - SISTEMA EDUHACK (IDs INT AUTOINCREMENT)
-- =====================================================

DELIMITER $$

-- =====================================================
-- PARTICIPANTES - ESTUDIANTES
-- =====================================================

-- CREATE: Crear estudiante completo
CREATE PROCEDURE sp_crear_estudiante(
    IN p_nombre VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_nivel_habilidad VARCHAR(50),
    IN p_habilidades JSON,
    IN p_grado VARCHAR(10),
    IN p_institucion VARCHAR(255),
    IN p_tiempo_disponible INT
)
BEGIN
    DECLARE v_participante_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    INSERT INTO participantes (tipo, nombre, email, nivel_habilidad, habilidades)
    VALUES ('estudiante', p_nombre, p_email, p_nivel_habilidad, p_habilidades);
    
    SET v_participante_id = LAST_INSERT_ID();
    
    INSERT INTO estudiantes (participante_id, grado, institucion, tiempo_disponible_semanal)
    VALUES (v_participante_id, p_grado, p_institucion, p_tiempo_disponible);
    
    COMMIT;
    
    SELECT 'Estudiante creado exitosamente' as mensaje, v_participante_id as id;
END$$

-- READ: Obtener estudiante por ID
CREATE PROCEDURE sp_obtener_estudiante_por_id(
    IN p_id INT
)
BEGIN
    SELECT 
        p.id, p.tipo, p.nombre, p.email, p.nivel_habilidad, p.habilidades,
        p.created_at, p.updated_at,
        e.grado, e.institucion, e.tiempo_disponible_semanal
    FROM participantes p
    INNER JOIN estudiantes e ON p.id = e.participante_id
    WHERE p.id = p_id AND p.tipo = 'estudiante';
END$$

-- READ: Listar todos los estudiantes
CREATE PROCEDURE sp_listar_estudiantes()
BEGIN
    SELECT 
        p.id, p.tipo, p.nombre, p.email, p.nivel_habilidad, p.habilidades,
        p.created_at, p.updated_at,
        e.grado, e.institucion, e.tiempo_disponible_semanal
    FROM participantes p
    INNER JOIN estudiantes e ON p.id = e.participante_id
    WHERE p.tipo = 'estudiante'
    ORDER BY p.nombre;
END$$

-- UPDATE: Actualizar estudiante
CREATE PROCEDURE sp_actualizar_estudiante(
    IN p_id INT,
    IN p_nombre VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_nivel_habilidad VARCHAR(50),
    IN p_habilidades JSON,
    IN p_grado VARCHAR(10),
    IN p_institucion VARCHAR(255),
    IN p_tiempo_disponible INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    UPDATE participantes 
    SET nombre = p_nombre, 
        email = p_email, 
        nivel_habilidad = p_nivel_habilidad,
        habilidades = p_habilidades,
        updated_at = NOW()
    WHERE id = p_id AND tipo = 'estudiante';
    
    UPDATE estudiantes 
    SET grado = p_grado,
        institucion = p_institucion,
        tiempo_disponible_semanal = p_tiempo_disponible
    WHERE participante_id = p_id;
    
    COMMIT;
    
    SELECT 'Estudiante actualizado exitosamente' as mensaje, p_id as id;
END$$

-- DELETE: Eliminar estudiante
CREATE PROCEDURE sp_eliminar_estudiante(
    IN p_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Las foreign keys CASCADE eliminarán automáticamente de estudiantes
    DELETE FROM participantes WHERE id = p_id AND tipo = 'estudiante';
    
    COMMIT;
    
    SELECT 'Estudiante eliminado exitosamente' as mensaje, p_id as id;
END$$

-- =====================================================
-- PARTICIPANTES - MENTORES TECNICOS
-- =====================================================

-- CREATE: Crear mentor técnico completo
CREATE PROCEDURE sp_crear_mentor_tecnico(
    IN p_nombre VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_nivel_habilidad VARCHAR(50),
    IN p_habilidades JSON,
    IN p_especialidad VARCHAR(255),
    IN p_experiencia INT,
    IN p_disponibilidad VARCHAR(255)
)
BEGIN
    DECLARE v_participante_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    INSERT INTO participantes (tipo, nombre, email, nivel_habilidad, habilidades)
    VALUES ('mentorTecnico', p_nombre, p_email, p_nivel_habilidad, p_habilidades);
    
    SET v_participante_id = LAST_INSERT_ID();
    
    INSERT INTO mentores_tecnicos (participante_id, especialidad, experiencia_anos, disponibilidad_horaria)
    VALUES (v_participante_id, p_especialidad, p_experiencia, p_disponibilidad);
    
    COMMIT;
    
    SELECT 'Mentor técnico creado exitosamente' as mensaje, v_participante_id as id;
END$$

-- READ: Obtener mentor por ID
CREATE PROCEDURE sp_obtener_mentor_por_id(
    IN p_id INT
)
BEGIN
    SELECT 
        p.id, p.tipo, p.nombre, p.email, p.nivel_habilidad, p.habilidades,
        p.created_at, p.updated_at,
        mt.especialidad, mt.experiencia_anos, mt.disponibilidad_horaria
    FROM participantes p
    INNER JOIN mentores_tecnicos mt ON p.id = mt.participante_id
    WHERE p.id = p_id AND p.tipo = 'mentorTecnico';
END$$

-- READ: Listar todos los mentores
CREATE PROCEDURE sp_listar_mentores()
BEGIN
    SELECT 
        p.id, p.tipo, p.nombre, p.email, p.nivel_habilidad, p.habilidades,
        p.created_at, p.updated_at,
        mt.especialidad, mt.experiencia_anos, mt.disponibilidad_horaria
    FROM participantes p
    INNER JOIN mentores_tecnicos mt ON p.id = mt.participante_id
    WHERE p.tipo = 'mentorTecnico'
    ORDER BY p.nombre;
END$$

-- UPDATE: Actualizar mentor
CREATE PROCEDURE sp_actualizar_mentor_tecnico(
    IN p_id INT,
    IN p_nombre VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_nivel_habilidad VARCHAR(50),
    IN p_habilidades JSON,
    IN p_especialidad VARCHAR(255),
    IN p_experiencia INT,
    IN p_disponibilidad VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    UPDATE participantes 
    SET nombre = p_nombre, 
        email = p_email, 
        nivel_habilidad = p_nivel_habilidad,
        habilidades = p_habilidades,
        updated_at = NOW()
    WHERE id = p_id AND tipo = 'mentorTecnico';
    
    UPDATE mentores_tecnicos 
    SET especialidad = p_especialidad,
        experiencia_anos = p_experiencia,
        disponibilidad_horaria = p_disponibilidad
    WHERE participante_id = p_id;
    
    COMMIT;
    
    SELECT 'Mentor técnico actualizado exitosamente' as mensaje, p_id as id;
END$$

-- DELETE: Eliminar mentor
CREATE PROCEDURE sp_eliminar_mentor_tecnico(
    IN p_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Las foreign keys CASCADE eliminarán automáticamente de mentores_tecnicos
    DELETE FROM participantes WHERE id = p_id AND tipo = 'mentorTecnico';
    
    COMMIT;
    
    SELECT 'Mentor técnico eliminado exitosamente' as mensaje, p_id as id;
END$$

-- =====================================================
-- RETOS REALES
-- =====================================================

-- CREATE: Crear reto real completo
CREATE PROCEDURE sp_crear_reto_real(
    IN p_titulo VARCHAR(255),
    IN p_descripcion TEXT,
    IN p_complejidad VARCHAR(50),
    IN p_areas_conocimiento JSON,
    IN p_entidad_colaboradora VARCHAR(255)
)
BEGIN
    DECLARE v_reto_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    INSERT INTO retos (tipo, titulo, descripcion, complejidad, areas_conocimiento)
    VALUES ('retoReal', p_titulo, p_descripcion, p_complejidad, p_areas_conocimiento);
    
    SET v_reto_id = LAST_INSERT_ID();
    
    INSERT INTO retos_reales (reto_id, entidad_colaboradora)
    VALUES (v_reto_id, p_entidad_colaboradora);
    
    COMMIT;
    
    SELECT 'Reto real creado exitosamente' as mensaje, v_reto_id as id;
END$$

-- READ: Obtener reto real por ID
CREATE PROCEDURE sp_obtener_reto_real_por_id(
    IN p_id INT
)
BEGIN
    SELECT 
        r.id, r.tipo, r.titulo, r.descripcion, r.complejidad, r.areas_conocimiento,
        r.created_at, r.updated_at,
        rr.entidad_colaboradora
    FROM retos r
    INNER JOIN retos_reales rr ON r.id = rr.reto_id
    WHERE r.id = p_id AND r.tipo = 'retoReal';
END$$

-- READ: Listar todos los retos reales
CREATE PROCEDURE sp_listar_retos_reales()
BEGIN
    SELECT 
        r.id, r.tipo, r.titulo, r.descripcion, r.complejidad, r.areas_conocimiento,
        r.created_at, r.updated_at,
        rr.entidad_colaboradora
    FROM retos r
    INNER JOIN retos_reales rr ON r.id = rr.reto_id
    WHERE r.tipo = 'retoReal'
    ORDER BY r.titulo;
END$$

-- UPDATE: Actualizar reto real
CREATE PROCEDURE sp_actualizar_reto_real(
    IN p_id INT,
    IN p_titulo VARCHAR(255),
    IN p_descripcion TEXT,
    IN p_complejidad VARCHAR(50),
    IN p_areas_conocimiento JSON,
    IN p_entidad_colaboradora VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    UPDATE retos 
    SET titulo = p_titulo,
        descripcion = p_descripcion,
        complejidad = p_complejidad,
        areas_conocimiento = p_areas_conocimiento,
        updated_at = NOW()
    WHERE id = p_id AND tipo = 'retoReal';
    
    UPDATE retos_reales 
    SET entidad_colaboradora = p_entidad_colaboradora
    WHERE reto_id = p_id;
    
    COMMIT;
    
    SELECT 'Reto real actualizado exitosamente' as mensaje, p_id as id;
END$$

-- DELETE: Eliminar reto real
CREATE PROCEDURE sp_eliminar_reto_real(
    IN p_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Las foreign keys CASCADE eliminarán automáticamente de retos_reales
    DELETE FROM retos WHERE id = p_id AND tipo = 'retoReal';
    
    COMMIT;
    
    SELECT 'Reto real eliminado exitosamente' as mensaje, p_id as id;
END$$

-- =====================================================
-- RETOS EXPERIMENTALES
-- =====================================================

-- CREATE: Crear reto experimental completo
CREATE PROCEDURE sp_crear_reto_experimental(
    IN p_titulo VARCHAR(255),
    IN p_descripcion TEXT,
    IN p_complejidad VARCHAR(50),
    IN p_areas_conocimiento JSON,
    IN p_enfoque_pedagogico VARCHAR(255)
)
BEGIN
    DECLARE v_reto_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    INSERT INTO retos (tipo, titulo, descripcion, complejidad, areas_conocimiento)
    VALUES ('retoExperimental', p_titulo, p_descripcion, p_complejidad, p_areas_conocimiento);
    
    SET v_reto_id = LAST_INSERT_ID();
    
    INSERT INTO retos_experimentales (reto_id, enfoque_pedagogico)
    VALUES (v_reto_id, p_enfoque_pedagogico);
    
    COMMIT;
    
    SELECT 'Reto experimental creado exitosamente' as mensaje, v_reto_id as id;
END$$

-- READ: Obtener reto experimental por ID
CREATE PROCEDURE sp_obtener_reto_experimental_por_id(
    IN p_id INT
)
BEGIN
    SELECT 
        r.id, r.tipo, r.titulo, r.descripcion, r.complejidad, r.areas_conocimiento,
        r.created_at, r.updated_at,
        re.enfoque_pedagogico
    FROM retos r
    INNER JOIN retos_experimentales re ON r.id = re.reto_id
    WHERE r.id = p_id AND r.tipo = 'retoExperimental';
END$$

-- READ: Listar todos los retos experimentales
CREATE PROCEDURE sp_listar_retos_experimentales()
BEGIN
    SELECT 
        r.id, r.tipo, r.titulo, r.descripcion, r.complejidad, r.areas_conocimiento,
        r.created_at, r.updated_at,
        re.enfoque_pedagogico
    FROM retos r
    INNER JOIN retos_experimentales re ON r.id = re.reto_id
    WHERE r.tipo = 'retoExperimental'
    ORDER BY r.titulo;
END$$

-- UPDATE: Actualizar reto experimental
CREATE PROCEDURE sp_actualizar_reto_experimental(
    IN p_id INT,
    IN p_titulo VARCHAR(255),
    IN p_descripcion TEXT,
    IN p_complejidad VARCHAR(50),
    IN p_areas_conocimiento JSON,
    IN p_enfoque_pedagogico VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    UPDATE retos 
    SET titulo = p_titulo,
        descripcion = p_descripcion,
        complejidad = p_complejidad,
        areas_conocimiento = p_areas_conocimiento,
        updated_at = NOW()
    WHERE id = p_id AND tipo = 'retoExperimental';
    
    UPDATE retos_experimentales 
    SET enfoque_pedagogico = p_enfoque_pedagogico
    WHERE reto_id = p_id;
    
    COMMIT;
    
    SELECT 'Reto experimental actualizado exitosamente' as mensaje, p_id as id;
END$$

-- DELETE: Eliminar reto experimental
CREATE PROCEDURE sp_eliminar_reto_experimental(
    IN p_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Las foreign keys CASCADE eliminarán automáticamente de retos_experimentales
    DELETE FROM retos WHERE id = p_id AND tipo = 'retoExperimental';
    
    COMMIT;
    
    SELECT 'Reto experimental eliminado exitosamente' as mensaje, p_id as id;
END$$

-- =====================================================
-- HACKATHONS
-- =====================================================

-- CREATE: Crear hackathon
CREATE PROCEDURE sp_crear_hackathon(
    IN p_nombre VARCHAR(255),
    IN p_descripcion TEXT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_lugar VARCHAR(255),
    IN p_estado VARCHAR(50)
)
BEGIN
    DECLARE v_hackathon_id INT;
    
    INSERT INTO hackathons (nombre, descripcion, fecha_inicio, fecha_fin, lugar, estado)
    VALUES (p_nombre, p_descripcion, p_fecha_inicio, p_fecha_fin, p_lugar, p_estado);
    
    SET v_hackathon_id = LAST_INSERT_ID();
    
    SELECT 'Hackathon creado exitosamente' as mensaje, v_hackathon_id as id;
END$$

-- READ: Obtener hackathon por ID
CREATE PROCEDURE sp_obtener_hackathon_por_id(
    IN p_id INT
)
BEGIN
    SELECT * FROM hackathons WHERE id = p_id;
END$$

-- READ: Listar todos los hackathons
CREATE PROCEDURE sp_listar_hackathons()
BEGIN
    SELECT * FROM hackathons ORDER BY fecha_inicio DESC;
END$$

-- UPDATE: Actualizar hackathon
CREATE PROCEDURE sp_actualizar_hackathon(
    IN p_id INT,
    IN p_nombre VARCHAR(255),
    IN p_descripcion TEXT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_lugar VARCHAR(255),
    IN p_estado VARCHAR(50)
)
BEGIN
    UPDATE hackathons 
    SET nombre = p_nombre,
        descripcion = p_descripcion,
        fecha_inicio = p_fecha_inicio,
        fecha_fin = p_fecha_fin,
        lugar = p_lugar,
        estado = p_estado
    WHERE id = p_id;
    
    SELECT 'Hackathon actualizado exitosamente' as mensaje, p_id as id;
END$$

-- DELETE: Eliminar hackathon
CREATE PROCEDURE sp_eliminar_hackathon(
    IN p_id INT
)
BEGIN
    DELETE FROM hackathons WHERE id = p_id;
    SELECT 'Hackathon eliminado exitosamente' as mensaje, p_id as id;
END$$

-- =====================================================
-- EQUIPOS
-- =====================================================

-- CREATE: Crear equipo
CREATE PROCEDURE sp_crear_equipo(
    IN p_nombre VARCHAR(255),
    IN p_hackathon_id INT
)
BEGIN
    DECLARE v_equipo_id INT;
    
    INSERT INTO equipos (nombre, hackathon_id)
    VALUES (p_nombre, p_hackathon_id);
    
    SET v_equipo_id = LAST_INSERT_ID();
    
    SELECT 'Equipo creado exitosamente' as mensaje, v_equipo_id as id;
END$$

-- READ: Obtener equipo por ID con estadísticas
CREATE PROCEDURE sp_obtener_equipo_por_id(
    IN p_id INT
)
BEGIN
    SELECT * FROM equipos_con_estadisticas WHERE id = p_id;
END$$

-- READ: Listar todos los equipos
CREATE PROCEDURE sp_listar_equipos()
BEGIN
    SELECT * FROM equipos_con_estadisticas ORDER BY nombre;
END$$

-- UPDATE: Actualizar equipo
CREATE PROCEDURE sp_actualizar_equipo(
    IN p_id INT,
    IN p_nombre VARCHAR(255),
    IN p_hackathon_id INT
)
BEGIN
    UPDATE equipos 
    SET nombre = p_nombre,
        hackathon_id = p_hackathon_id,
        updated_at = NOW()
    WHERE id = p_id;
    
    SELECT 'Equipo actualizado exitosamente' as mensaje, p_id as id;
END$$

-- DELETE: Eliminar equipo
CREATE PROCEDURE sp_eliminar_equipo(
    IN p_id INT
)
BEGIN
    DELETE FROM equipos WHERE id = p_id;
    SELECT 'Equipo eliminado exitosamente' as mensaje, p_id as id;
END$$

-- =====================================================
-- PROCEDIMIENTOS ADICIONALES PARA RELACIONES
-- =====================================================

-- Agregar participante a equipo
CREATE PROCEDURE sp_agregar_participante_equipo(
    IN p_equipo_id INT,
    IN p_participante_id INT,
    IN p_rol VARCHAR(100)
)
BEGIN
    INSERT INTO equipo_participantes (equipo_id, participante_id, rol_en_equipo)
    VALUES (p_equipo_id, p_participante_id, p_rol);
    
    SELECT 'Participante agregado al equipo exitosamente' as mensaje;
END$$

-- Quitar participante de equipo
CREATE PROCEDURE sp_quitar_participante_equipo(
    IN p_equipo_id INT,
    IN p_participante_id INT
)
BEGIN
    DELETE FROM equipo_participantes 
    WHERE equipo_id = p_equipo_id AND participante_id = p_participante_id;
    
    SELECT 'Participante removido del equipo exitosamente' as mensaje;
END$$

-- Asignar reto a equipo
CREATE PROCEDURE sp_asignar_reto_equipo(
    IN p_equipo_id INT,
    IN p_reto_id INT
)
BEGIN
    INSERT INTO equipo_retos (equipo_id, reto_id, estado)
    VALUES (p_equipo_id, p_reto_id, 'asignado');
    
    SELECT 'Reto asignado al equipo exitosamente' as mensaje;
END$$

-- Desasignar reto de equipo
CREATE PROCEDURE sp_desasignar_reto_equipo(
    IN p_equipo_id INT,
    IN p_reto_id INT
)
BEGIN
    DELETE FROM equipo_retos 
    WHERE equipo_id = p_equipo_id AND reto_id = p_reto_id;
    
    SELECT 'Reto desasignado del equipo exitosamente' as mensaje;
END$$

-- Actualizar progreso de reto en equipo
CREATE PROCEDURE sp_actualizar_progreso_reto(
    IN p_equipo_id INT,
    IN p_reto_id INT,
    IN p_estado VARCHAR(50),
    IN p_progreso INT,
    IN p_notas TEXT
)
BEGIN
    UPDATE equipo_retos 
    SET estado = p_estado,
        progreso_porcentaje = p_progreso,
        notas = p_notas,
        fecha_completion = CASE WHEN p_estado = 'completado' THEN NOW() ELSE fecha_completion END
    WHERE equipo_id = p_equipo_id AND reto_id = p_reto_id;
    
    SELECT 'Progreso actualizado exitosamente' as mensaje;
END$$

-- Obtener participantes de un equipo
CREATE PROCEDURE sp_obtener_participantes_equipo(
    IN p_equipo_id INT
)
BEGIN
    SELECT 
        p.id, p.tipo, p.nombre, p.email, p.nivel_habilidad,
        ep.rol_en_equipo, ep.fecha_union
    FROM participantes p
    INNER JOIN equipo_participantes ep ON p.id = ep.participante_id
    WHERE ep.equipo_id = p_equipo_id
    ORDER BY ep.fecha_union;
END$$

-- Obtener retos de un equipo
CREATE PROCEDURE sp_obtener_retos_equipo(
    IN p_equipo_id INT
)
BEGIN
    SELECT 
        r.id, r.tipo, r.titulo, r.descripcion, r.complejidad,
        er.estado, er.progreso_porcentaje, er.fecha_asignacion, er.notas
    FROM retos r
    INNER JOIN equipo_retos er ON r.id = er.reto_id
    WHERE er.equipo_id = p_equipo_id
    ORDER BY er.fecha_asignacion;
END$$

-- Obtener equipos de un reto
CREATE PROCEDURE sp_obtener_equipos_reto(
    IN p_reto_id INT
)
BEGIN
    SELECT 
        e.id, e.nombre, e.hackathon_id,
        er.estado, er.progreso_porcentaje,
        COUNT(ep.participante_id) as total_miembros
    FROM equipos e
    INNER JOIN equipo_retos er ON e.id = er.equipo_id
    LEFT JOIN equipo_participantes ep ON e.id = ep.equipo_id
    WHERE er.reto_id = p_reto_id
    GROUP BY e.id, e.nombre, e.hackathon_id, er.estado, er.progreso_porcentaje
    ORDER BY er.progreso_porcentaje DESC;
END$$

-- Listar todos los participantes (estudiantes y mentores)
CREATE PROCEDURE sp_listar_todos_participantes()
BEGIN
    SELECT * FROM participantes_completos ORDER BY nombre;
END$$

-- Listar todos los retos (reales y experimentales)
CREATE PROCEDURE sp_listar_todos_retos()
BEGIN
    SELECT * FROM retos_completos ORDER BY titulo;
END$$

-- Obtener estadísticas de un hackathon
CREATE PROCEDURE sp_obtener_estadisticas_hackathon(
    IN p_hackathon_id INT
)
BEGIN
    SELECT 
        h.id,
        h.nombre as hackathon_nombre,
        COUNT(DISTINCT e.id) as total_equipos,
        COUNT(DISTINCT ep.participante_id) as total_participantes,
        COUNT(DISTINCT CASE WHEN p.tipo = 'estudiante' THEN ep.participante_id END) as total_estudiantes,
        COUNT(DISTINCT CASE WHEN p.tipo = 'mentorTecnico' THEN ep.participante_id END) as total_mentores,
        COUNT(DISTINCT er.reto_id) as total_retos_activos,
        COUNT(DISTINCT CASE WHEN er.estado = 'completado' THEN er.reto_id END) as total_retos_completados,
        COALESCE(AVG(er.progreso_porcentaje), 0) as progreso_general
    FROM hackathons h
    LEFT JOIN equipos e ON h.id = e.hackathon_id
    LEFT JOIN equipo_participantes ep ON e.id = ep.equipo_id
    LEFT JOIN participantes p ON ep.participante_id = p.id
    LEFT JOIN equipo_retos er ON e.id = er.equipo_id
    WHERE h.id = p_hackathon_id
    GROUP BY h.id, h.nombre;
END$$

-- Buscar participantes por habilidades
CREATE PROCEDURE sp_buscar_participantes_por_habilidad(
    IN p_habilidad VARCHAR(255)
)
BEGIN
    SELECT * FROM participantes_completos 
    WHERE JSON_SEARCH(habilidades, 'one', p_habilidad) IS NOT NULL
    ORDER BY nombre;
END$$

-- Buscar retos por área de conocimiento
CREATE PROCEDURE sp_buscar_retos_por_area(
    IN p_area VARCHAR(255)
)
BEGIN
    SELECT * FROM retos_completos 
    WHERE JSON_SEARCH(areas_conocimiento, 'one', p_area) IS NOT NULL
    ORDER BY titulo;
END$$

DELIMITER ;

