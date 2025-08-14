DELIMITER $$

-- =========================================================
-- LISTAR ESTUDIANTES
-- =========================================================
DROP PROCEDURE IF EXISTS sp_estudiante_list$$
CREATE PROCEDURE sp_estudiante_list()
BEGIN
    SELECT
        e.id,
        p.codigo,
        p.nombre,
        p.email,
        p.nivelHabilidad,
        p.habilidades,
        e.grado,
        e.institucion,
        e.tiempoDisponibleSemanal,
        p.created_at
    FROM Estudiante e
    JOIN Participante p ON e.id = p.id
    WHERE p.tipo = 'ESTUDIANTE'
    ORDER BY p.nombre ASC;
END$$

-- =========================================================
-- CREAR ESTUDIANTE
-- =========================================================
DROP PROCEDURE IF EXISTS sp_create_estudiante$$
CREATE PROCEDURE sp_create_estudiante(
    IN p_codigo VARCHAR(50),
    IN p_nombre VARCHAR(150),
    IN p_email VARCHAR(200),
    IN p_nivelHabilidad ENUM('basico','intermedio','avanzado'),
    IN p_habilidades JSON,
    IN p_grado VARCHAR(30),
    IN p_institucion VARCHAR(150),
    IN p_tiempoDisponibleSemanal INT
)
BEGIN
    DECLARE v_new_part_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO Participante (codigo, tipo, nombre, email, nivelHabilidad, habilidades)
    VALUES (p_codigo, 'ESTUDIANTE', p_nombre, p_email, p_nivelHabilidad, p_habilidades);

    SET v_new_part_id = LAST_INSERT_ID();

    INSERT INTO Estudiante (id, grado, institucion, tiempoDisponibleSemanal)
    VALUES (v_new_part_id, p_grado, p_institucion, p_tiempoDisponibleSemanal);

    COMMIT;

    SELECT v_new_part_id AS estudiante_id;
END$$

-- =========================================================
-- BUSCAR ESTUDIANTE POR ID
-- =========================================================
DROP PROCEDURE IF EXISTS sp_find_estudiante$$
CREATE PROCEDURE sp_find_estudiante(IN p_id INT)
BEGIN
    SELECT
        e.id,
        p.codigo,
        p.nombre,
        p.email,
        p.nivelHabilidad,
        p.habilidades,
        e.grado,
        e.institucion,
        e.tiempoDisponibleSemanal,
        p.created_at
    FROM Estudiante e
    JOIN Participante p ON e.id = p.id
    WHERE p.tipo = 'ESTUDIANTE'
      AND e.id = p_id;
END$$

-- =========================================================
-- ACTUALIZAR ESTUDIANTE
-- =========================================================
DROP PROCEDURE IF EXISTS sp_update_estudiante$$
CREATE PROCEDURE sp_update_estudiante(
    IN p_id INT,
    IN p_nombre VARCHAR(150),
    IN p_email VARCHAR(200),
    IN p_nivelHabilidad ENUM('basico','intermedio','avanzado'),
    IN p_habilidades JSON,
    IN p_grado VARCHAR(30),
    IN p_institucion VARCHAR(150),
    IN p_tiempoDisponibleSemanal INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    -- Validar existencia
    IF NOT EXISTS (
        SELECT 1 FROM Estudiante e
        JOIN Participante p ON e.id = p.id
        WHERE e.id = p_id AND p.tipo = 'ESTUDIANTE'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estudiante no encontrado';
    END IF;

    START TRANSACTION;

    UPDATE Participante
    SET nombre = p_nombre,
        email = p_email,
        nivelHabilidad = p_nivelHabilidad,
        habilidades = p_habilidades
    WHERE id = p_id;

    UPDATE Estudiante
    SET grado = p_grado,
        institucion = p_institucion,
        tiempoDisponibleSemanal = p_tiempoDisponibleSemanal
    WHERE id = p_id;

    COMMIT;

    SELECT 1 AS OK;
END$$

-- =========================================================
-- ELIMINAR ESTUDIANTE
-- =========================================================
DROP PROCEDURE IF EXISTS sp_delete_estudiante$$
CREATE PROCEDURE sp_delete_estudiante(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Basta con borrar el Participante, por ON DELETE CASCADE eliminará Estudiante
    DELETE FROM Participante
    WHERE id = p_id AND tipo = 'ESTUDIANTE';

    COMMIT;

    SELECT 1 AS OK;
END$$

DELIMITER ;
-- =========================================================


-- para ver
