DELIMITER $$

-- =========================================================
-- LISTAR MENTORES TÉCNICOS
-- =========================================================
DROP PROCEDURE IF EXISTS sp_mentor_tecnico_list$$
CREATE PROCEDURE sp_mentor_tecnico_list()
BEGIN
    SELECT
        m.id,
        p.codigo,
        p.nombre,
        p.email,
        p.nivelHabilidad,
        p.habilidades,
        m.especialidad,
        m.experiencia,
        m.disponibilidadHoraria,
        p.created_at
    FROM MentorTecnico m
    JOIN Participante p ON m.id = p.id
    WHERE p.tipo = 'MENTOR_TECNICO'
    ORDER BY p.nombre ASC;
END$$

-- =========================================================
-- CREAR MENTOR TÉCNICO
-- =========================================================
DROP PROCEDURE IF EXISTS sp_create_mentor_tecnico$$
CREATE PROCEDURE sp_create_mentor_tecnico(
    IN p_codigo VARCHAR(50),
    IN p_nombre VARCHAR(150),
    IN p_email VARCHAR(200),
    IN p_nivelHabilidad ENUM('basico','intermedio','avanzado'),
    IN p_habilidades JSON,
    IN p_especialidad VARCHAR(150),
    IN p_experiencia INT,
    IN p_disponibilidadHoraria VARCHAR(150)
)
BEGIN
    DECLARE v_new_part_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO Participante (codigo, tipo, nombre, email, nivelHabilidad, habilidades)
    VALUES (p_codigo, 'MENTOR_TECNICO', p_nombre, p_email, p_nivelHabilidad, p_habilidades);

    SET v_new_part_id = LAST_INSERT_ID();

    INSERT INTO MentorTecnico (id, especialidad, experiencia, disponibilidadHoraria)
    VALUES (v_new_part_id, p_especialidad, p_experiencia, p_disponibilidadHoraria);

    COMMIT;

    SELECT v_new_part_id AS mentor_id;
END$$

-- =========================================================
-- BUSCAR MENTOR TÉCNICO POR ID
-- =========================================================
DROP PROCEDURE IF EXISTS sp_find_mentor_tecnico$$
CREATE PROCEDURE sp_find_mentor_tecnico(IN p_id INT)
BEGIN
    SELECT
        m.id,
        p.codigo,
        p.nombre,
        p.email,
        p.nivelHabilidad,
        p.habilidades,
        m.especialidad,
        m.experiencia,
        m.disponibilidadHoraria,
        p.created_at
    FROM MentorTecnico m
    JOIN Participante p ON m.id = p.id
    WHERE p.tipo = 'MENTOR_TECNICO'
      AND m.id = p_id;
END$$

-- =========================================================
-- ACTUALIZAR MENTOR TÉCNICO
-- =========================================================
DROP PROCEDURE IF EXISTS sp_update_mentor_tecnico$$
CREATE PROCEDURE sp_update_mentor_tecnico(
    IN p_id INT,
    IN p_nombre VARCHAR(150),
    IN p_email VARCHAR(200),
    IN p_nivelHabilidad ENUM('basico','intermedio','avanzado'),
    IN p_habilidades JSON,
    IN p_especialidad VARCHAR(150),
    IN p_experiencia INT,
    IN p_disponibilidadHoraria VARCHAR(150)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    -- Validar existencia
    IF NOT EXISTS (
        SELECT 1 FROM MentorTecnico m
        JOIN Participante p ON m.id = p.id
        WHERE m.id = p_id AND p.tipo = 'MENTOR_TECNICO'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mentor Técnico no encontrado';
    END IF;

    START TRANSACTION;

    UPDATE Participante
    SET nombre = p_nombre,
        email = p_email,
        nivelHabilidad = p_nivelHabilidad,
        habilidades = p_habilidades
    WHERE id = p_id;

    UPDATE MentorTecnico
    SET especialidad = p_especialidad,
        experiencia = p_experiencia,
        disponibilidadHoraria = p_disponibilidadHoraria
    WHERE id = p_id;

    COMMIT;

    SELECT 1 AS OK;
END$$

-- =========================================================
-- ELIMINAR MENTOR TÉCNICO
-- =========================================================
DROP PROCEDURE IF EXISTS sp_delete_mentor_tecnico$$
CREATE PROCEDURE sp_delete_mentor_tecnico(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Basta con borrar el Participante, ON DELETE CASCADE eliminará el subtipo
    DELETE FROM Participante
    WHERE id = p_id AND tipo = 'MENTOR_TECNICO';

    COMMIT;

    SELECT 1 AS OK;
END$$

DELIMITER ;


CALL sp_mentor_tecnico_list