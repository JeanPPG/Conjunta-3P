DELIMITER $$

-- =========================================================
-- LISTAR EQUIPOS
-- =========================================================
DROP PROCEDURE IF EXISTS sp_equipo_list$$
CREATE PROCEDURE sp_equipo_list()
BEGIN
    SELECT 
        e.id,
        e.codigo,
        e.nombre,
        e.hackathon_id,
        h.nombre AS hackathon_nombre,
        e.created_at
    FROM Equipo e
    JOIN Hackathon h ON e.hackathon_id = h.id
    ORDER BY e.created_at DESC;
END$$

-- =========================================================
-- CREAR EQUIPO CON PARTICIPANTES
-- =========================================================
DROP PROCEDURE IF EXISTS sp_create_equipo$$
CREATE PROCEDURE sp_create_equipo(
    IN p_codigo VARCHAR(50),
    IN p_nombre VARCHAR(150),
    IN p_hackathon_id INT,
    IN p_participantes JSON   -- Array de objetos [{id: X, rol: 'ESTUDIANTE'}, {...}]
)
BEGIN
    DECLARE v_new_equipo_id INT;
    DECLARE v_idx INT DEFAULT 0;
    DECLARE v_total INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Crear equipo
    INSERT INTO Equipo (codigo, nombre, hackathon_id)
    VALUES (p_codigo, p_nombre, p_hackathon_id);
    SET v_new_equipo_id = LAST_INSERT_ID();

    -- Insertar participantes en EquipoParticipante
    SET v_total = JSON_LENGTH(p_participantes);
    WHILE v_idx < v_total DO
        INSERT INTO EquipoParticipante (equipo_id, participante_id, rol)
        VALUES (
            v_new_equipo_id,
            JSON_EXTRACT(p_participantes, CONCAT('$[', v_idx, '].id')),
            JSON_UNQUOTE(JSON_EXTRACT(p_participantes, CONCAT('$[', v_idx, '].rol')))
        );
        SET v_idx = v_idx + 1;
    END WHILE;

    COMMIT;

    SELECT v_new_equipo_id AS equipo_id;
END$$

-- =========================================================
-- ASIGNAR RETO A EQUIPO (M:N)
-- =========================================================
DROP PROCEDURE IF EXISTS sp_asignar_reto_a_equipo$$
CREATE PROCEDURE sp_asignar_reto_a_equipo(
    IN p_equipo_id INT,
    IN p_reto_id INT,
    IN p_estado ENUM('pendiente','en_progreso','completado','abandonado')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Insertar o actualizar si ya existe
    INSERT INTO EquipoReto (equipo_id, reto_id, estado, avance)
    VALUES (p_equipo_id, p_reto_id, p_estado, 0)
    ON DUPLICATE KEY UPDATE
        estado = VALUES(estado);

    COMMIT;

    SELECT 1 AS OK;
END$$

-- =========================================================
-- LISTAR RETOS DE UN EQUIPO
-- =========================================================
DROP PROCEDURE IF EXISTS sp_equipo_retos$$
CREATE PROCEDURE sp_equipo_retos(IN p_equipo_id INT)
BEGIN
    SELECT 
        r.id,
        r.codigo,
        r.titulo,
        r.tipo,
        r.complejidad,
        er.estado,
        er.avance
    FROM EquipoReto er
    JOIN Reto r ON er.reto_id = r.id
    WHERE er.equipo_id = p_equipo_id;
END$$

-- =========================================================
-- LISTAR EQUIPOS DE UN RETO
-- =========================================================
DROP PROCEDURE IF EXISTS sp_reto_equipos$$
CREATE PROCEDURE sp_reto_equipos(IN p_reto_id INT)
BEGIN
    SELECT 
        e.id,
        e.codigo,
        e.nombre,
        COUNT(ep.participante_id) AS miembros
    FROM EquipoReto er
    JOIN Equipo e ON er.equipo_id = e.id
    LEFT JOIN EquipoParticipante ep ON e.id = ep.equipo_id
    WHERE er.reto_id = p_reto_id
    GROUP BY e.id, e.codigo, e.nombre;
END$$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_retos_populares_por_hackathon$$
CREATE PROCEDURE sp_retos_populares_por_hackathon(IN p_hackathon_id INT)
BEGIN

    SELECT 
        r.id            AS reto_id,
        r.titulo,
        r.tipo,
        COUNT(er.equipo_id) AS total_equipos
    FROM Reto r
    LEFT JOIN EquipoReto er ON r.id = er.reto_id
    LEFT JOIN Equipo e      ON er.equipo_id = e.id
    WHERE r.hackathon_id = p_hackathon_id
    GROUP BY r.id, r.titulo, r.tipo
    ORDER BY total_equipos DESC, r.titulo ASC;
END$$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_datos_para_matcheo$$
CREATE PROCEDURE sp_datos_para_matcheo(IN p_hackathon_id INT)
BEGIN

    SELECT 
        p.id,
        p.nombre,
        p.tipo, -- ESTUDIANTE / MENTOR
        p.nivelHabilidad,
        JSON_ARRAYAGG(h.habilidad) AS habilidades,
        CASE 
            WHEN p.tipo = 'ESTUDIANTE' 
                THEN JSON_OBJECT(
                    'grado', e.grado,
                    'institucion', e.institucion,
                    'tiempoDisponibleSemanal', e.tiempoDisponibleSemanal
                )
            WHEN p.tipo = 'MENTOR_TECNICO'
                THEN JSON_OBJECT(
                    'especialidad', m.especialidad,
                    'experiencia', m.experiencia,
                    'disponibilidadHoraria', m.disponibilidadHoraria
                )
        END AS detalles
    FROM Participante p
    LEFT JOIN Estudiante e     ON p.id = e.id
    LEFT JOIN MentorTecnico m  ON p.id = m.id
    LEFT JOIN ParticipanteHabilidad h ON p.id = h.participante_id
    WHERE p.hackathon_id = p_hackathon_id
    GROUP BY p.id;

    -- Retos
    SELECT 
        r.id,
        r.titulo,
        r.tipo,
        r.complejidad,
        r.areasConocimiento,
        CASE 
            WHEN r.tipo = 'REAL' 
                THEN rr.entidadColaboradora
            WHEN r.tipo = 'EXPERIMENTAL'
                THEN rexp.enfoquePedagogico
        END AS extra_info
    FROM Reto r
    LEFT JOIN RetoReal rr           ON r.id = rr.id
    LEFT JOIN RetoExperimental rexp ON r.id = rexp.id
    WHERE r.hackathon_id = p_hackathon_id;
END$$

DELIMITER ;
