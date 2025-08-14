DELIMITER $$

DROP PROCEDURE IF EXISTS sp_estudiante_list$$
CREATE PROCEDURE sp_estudiante_list()
BEGIN
    SELECT 
        p.id,
        p.tipo,
        p.nombre,
        p.email,
        p.nivelHabilidad,
        p.habilidades,
        e.grado,
        e.institucion,
        e.tiempoDisponibleSemanal,
        p.created_at
    FROM Participante p
    JOIN Estudiante e ON p.id = e.id
    ORDER BY p.nombre ASC;
END$$

DROP PROCEDURE IF EXISTS sp_create_estudiante$$
CREATE PROCEDURE sp_create_estudiante(
    IN p_nombre VARCHAR(150),
    IN p_email VARCHAR(200),
    IN p_nivelHabilidad ENUM('basico','intermedio','avanzado'),
    IN p_habilidades JSON,
    IN p_grado VARCHAR(30),
    IN p_institucion VARCHAR(150),
    IN p_tiempoDisponible INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; END;

    START TRANSACTION;

    INSERT INTO Participante(tipo, nombre, email, nivelHabilidad, habilidades)
    VALUES ('ESTUDIANTE', p_nombre, p_email, p_nivelHabilidad, p_habilidades);

    SET @new_id = LAST_INSERT_ID();

    INSERT INTO Estudiante(id, grado, institucion, tiempoDisponibleSemanal)
    VALUES (@new_id, p_grado, p_institucion, p_tiempoDisponible);

    COMMIT;

    SELECT @new_id AS id;
END$$

DROP PROCEDURE IF EXISTS sp_find_estudiante$$
CREATE PROCEDURE sp_find_estudiante(IN p_id INT)
BEGIN
    SELECT 
        p.id,
        p.tipo,
        p.nombre,
        p.email,
        p.nivelHabilidad,
        p.habilidades,
        e.grado,
        e.institucion,
        e.tiempoDisponibleSemanal,
        p.created_at
    FROM Participante p
    JOIN Estudiante e ON p.id = e.id
    WHERE p.id = p_id;
END$$

DROP PROCEDURE IF EXISTS sp_update_estudiante$$
CREATE PROCEDURE sp_update_estudiante(
    IN p_id INT,
    IN p_nombre VARCHAR(150),
    IN p_email VARCHAR(200),
    IN p_nivelHabilidad ENUM('basico','intermedio','avanzado'),
    IN p_habilidades JSON,
    IN p_grado VARCHAR(30),
    IN p_institucion VARCHAR(150),
    IN p_tiempoDisponible INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; END;

    START TRANSACTION;

    UPDATE Participante
    SET nombre = p_nombre,
        email = p_email,
        nivelHabilidad = p_nivelHabilidad,
        habilidades = p_habilidades
    WHERE id = p_id AND tipo = 'ESTUDIANTE';

    UPDATE Estudiante
    SET grado = p_grado,
        institucion = p_institucion,
        tiempoDisponibleSemanal = p_tiempoDisponible
    WHERE id = p_id;

    COMMIT;

    SELECT 1 AS OK;
END$$

DROP PROCEDURE IF EXISTS sp_delete_estudiante$$
CREATE PROCEDURE sp_delete_estudiante(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; END;
    START TRANSACTION;

    DELETE FROM Estudiante WHERE id = p_id;
    DELETE FROM Participante WHERE id = p_id AND tipo = 'ESTUDIANTE';

    COMMIT;
    SELECT 1 AS OK;
END$$

DELIMITER ;
