DELIMITER $$

-- =========================================================
-- LISTAR RETOS REALES
-- =========================================================
DROP PROCEDURE IF EXISTS sp_reto_real_list$$
CREATE PROCEDURE sp_reto_real_list()
BEGIN
    SELECT
        r.id,
        r.codigo,
        r.hackathon_id,
        r.titulo,
        r.descripcion,
        r.complejidad,
        r.areasConocimiento,
        r.estado,
        rr.entidadColaboradora,
        r.created_at
    FROM RetoReal rr
    JOIN Reto r ON rr.id = r.id
    WHERE r.tipo = 'REAL'
    ORDER BY r.created_at DESC;
END$$

-- =========================================================
-- CREAR RETO REAL
-- =========================================================
DROP PROCEDURE IF EXISTS sp_create_reto_real$$
CREATE PROCEDURE sp_create_reto_real(
    IN p_codigo VARCHAR(50),
    IN p_hackathon_id INT,
    IN p_titulo VARCHAR(200),
    IN p_descripcion TEXT,
    IN p_complejidad ENUM('facil','media','dificil'),
    IN p_areasConocimiento JSON,
    IN p_estado ENUM('ACTIVO','INACTIVO'),
    IN p_entidadColaboradora VARCHAR(200)
)
BEGIN
    DECLARE v_new_reto_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO Reto (codigo, hackathon_id, tipo, titulo, descripcion, complejidad, areasConocimiento, estado)
    VALUES (p_codigo, p_hackathon_id, 'REAL', p_titulo, p_descripcion, p_complejidad, p_areasConocimiento, p_estado);

    SET v_new_reto_id = LAST_INSERT_ID();

    INSERT INTO RetoReal (id, entidadColaboradora)
    VALUES (v_new_reto_id, p_entidadColaboradora);

    COMMIT;

    SELECT v_new_reto_id AS reto_id;
END$$

-- =========================================================
-- BUSCAR RETO REAL POR ID
-- =========================================================
DROP PROCEDURE IF EXISTS sp_find_reto_real$$
CREATE PROCEDURE sp_find_reto_real(IN p_id INT)
BEGIN
    SELECT
        r.id,
        r.codigo,
        r.hackathon_id,
        r.titulo,
        r.descripcion,
        r.complejidad,
        r.areasConocimiento,
        r.estado,
        rr.entidadColaboradora,
        r.created_at
    FROM RetoReal rr
    JOIN Reto r ON rr.id = r.id
    WHERE r.tipo = 'REAL'
      AND r.id = p_id;
END$$

-- =========================================================
-- ACTUALIZAR RETO REAL
-- =========================================================
DROP PROCEDURE IF EXISTS sp_update_reto_real$$
CREATE PROCEDURE sp_update_reto_real(
    IN p_id INT,
    IN p_hackathon_id INT,
    IN p_titulo VARCHAR(200),
    IN p_descripcion TEXT,
    IN p_complejidad ENUM('facil','media','dificil'),
    IN p_areasConocimiento JSON,
    IN p_estado ENUM('ACTIVO','INACTIVO'),
    IN p_entidadColaboradora VARCHAR(200)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    -- Validar existencia
    IF NOT EXISTS (
        SELECT 1 FROM RetoReal rr
        JOIN Reto r ON rr.id = r.id
        WHERE r.id = p_id AND r.tipo = 'REAL'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reto Real no encontrado';
    END IF;

    START TRANSACTION;

    UPDATE Reto
    SET hackathon_id      = p_hackathon_id,
        titulo            = p_titulo,
        descripcion       = p_descripcion,
        complejidad       = p_complejidad,
        areasConocimiento = p_areasConocimiento,
        estado            = p_estado
    WHERE id = p_id;

    UPDATE RetoReal
    SET entidadColaboradora = p_entidadColaboradora
    WHERE id = p_id;

    COMMIT;

    SELECT 1 AS OK;
END$$

-- =========================================================
-- ELIMINAR RETO REAL
-- =========================================================
DROP PROCEDURE IF EXISTS sp_delete_reto_real$$
CREATE PROCEDURE sp_delete_reto_real(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Basta con borrar el padre Reto, ON DELETE CASCADE eliminará el subtipo
    DELETE FROM Reto
    WHERE id = p_id AND tipo = 'REAL';

    COMMIT;

    SELECT 1 AS OK;
END$$

DELIMITER ;


CALL sp_reto_real_list