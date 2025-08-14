DELIMITER $$

-- =========================================================
-- LISTAR RETOS EXPERIMENTALES
-- =========================================================
DROP PROCEDURE IF EXISTS sp_reto_experimental_list$$
CREATE PROCEDURE sp_reto_experimental_list()
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
        rexp.enfoquePedagogico,
        r.created_at
    FROM RetoExperimental rexp
    JOIN Reto r ON rexp.id = r.id
    WHERE r.tipo = 'EXPERIMENTAL'
    ORDER BY r.created_at DESC;
END$$

-- =========================================================
-- CREAR RETO EXPERIMENTAL
-- =========================================================
DROP PROCEDURE IF EXISTS sp_create_reto_experimental$$
CREATE PROCEDURE sp_create_reto_experimental(
    IN p_codigo VARCHAR(50),
    IN p_hackathon_id INT,
    IN p_titulo VARCHAR(200),
    IN p_descripcion TEXT,
    IN p_complejidad ENUM('facil','media','dificil'),
    IN p_areasConocimiento JSON,
    IN p_estado ENUM('ACTIVO','INACTIVO'),
    IN p_enfoquePedagogico VARCHAR(100)
)
BEGIN
    DECLARE v_new_reto_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO Reto (codigo, hackathon_id, tipo, titulo, descripcion, complejidad, areasConocimiento, estado)
    VALUES (p_codigo, p_hackathon_id, 'EXPERIMENTAL', p_titulo, p_descripcion, p_complejidad, p_areasConocimiento, p_estado);

    SET v_new_reto_id = LAST_INSERT_ID();

    INSERT INTO RetoExperimental (id, enfoquePedagogico)
    VALUES (v_new_reto_id, p_enfoquePedagogico);

    COMMIT;

    SELECT v_new_reto_id AS reto_id;
END$$

-- =========================================================
-- BUSCAR RETO EXPERIMENTAL POR ID
-- =========================================================
DROP PROCEDURE IF EXISTS sp_find_reto_experimental$$
CREATE PROCEDURE sp_find_reto_experimental(IN p_id INT)
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
        rexp.enfoquePedagogico,
        r.created_at
    FROM RetoExperimental rexp
    JOIN Reto r ON rexp.id = r.id
    WHERE r.tipo = 'EXPERIMENTAL'
      AND r.id = p_id;
END$$

-- =========================================================
-- ACTUALIZAR RETO EXPERIMENTAL
-- =========================================================
DROP PROCEDURE IF EXISTS sp_update_reto_experimental$$
CREATE PROCEDURE sp_update_reto_experimental(
    IN p_id INT,
    IN p_hackathon_id INT,
    IN p_titulo VARCHAR(200),
    IN p_descripcion TEXT,
    IN p_complejidad ENUM('facil','media','dificil'),
    IN p_areasConocimiento JSON,
    IN p_estado ENUM('ACTIVO','INACTIVO'),
    IN p_enfoquePedagogico VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    -- Validar existencia
    IF NOT EXISTS (
        SELECT 1 FROM RetoExperimental rexp
        JOIN Reto r ON rexp.id = r.id
        WHERE r.id = p_id AND r.tipo = 'EXPERIMENTAL'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reto Experimental no encontrado';
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

    UPDATE RetoExperimental
    SET enfoquePedagogico = p_enfoquePedagogico
    WHERE id = p_id;

    COMMIT;

    SELECT 1 AS OK;
END$$

-- =========================================================
-- ELIMINAR RETO EXPERIMENTAL
-- =========================================================
DROP PROCEDURE IF EXISTS sp_delete_reto_experimental$$
CREATE PROCEDURE sp_delete_reto_experimental(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Basta con borrar en Reto, ON DELETE CASCADE eliminará el subtipo
    DELETE FROM Reto
    WHERE id = p_id AND tipo = 'EXPERIMENTAL';

    COMMIT;

    SELECT 1 AS OK;
END$$

DELIMITER ;
