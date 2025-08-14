DELIMITER $$

DROP PROCEDURE IF EXISTS sp_mentor_list$$
CREATE PROCEDURE sp_mentor_list()
BEGIN
    SELECT 
        p.id,
        p.tipo,
        p.nombre,
        p.email,
        p.nivelHabilidad,
        p.habilidades,
        m.especialidad,
        m.experiencia,
        m.disponibilidadHoraria,
        p.created_at
    FROM Participante p
    JOIN MentorTecnico m ON p.id = m.id
    ORDER BY p.nombre ASC;
END$$

DROP PROCEDURE IF EXISTS sp_create_mentor$$
CREATE PROCEDURE sp_create_mentor(
    IN p_nombre VARCHAR(150),
    IN p_email VARCHAR(200),
    IN p_nivelHabilidad ENUM('basico','intermedio','avanzado'),
    IN p_habilidades JSON,
    IN p_especialidad VARCHAR(150),
    IN p_experiencia INT,
    IN p_disponibilidad VARCHAR(150)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; END;
    START TRANSACTION;

    INSERT INTO Participante(tipo, nombre, email, nivelHabilidad, habilidades)
    VALUES ('MENTOR_TECNICO', p_nombre, p_email, p_nivelHabilidad, p_habilidades);

    SET @new_id = LAST_INSERT_ID();

    INSERT INTO MentorTecnico(id, especialidad, experiencia, disponibilidadHoraria)
    VALUES (@new_id, p_especialidad, p_experiencia, p_disponibilidad);

    COMMIT;

    SELECT @new_id AS id;
END$$

DROP PROCEDURE IF EXISTS sp_find_mentor$$
CREATE PROCEDURE sp_find_mentor(IN p_id INT)
BEGIN
    SELECT 
        p.id,
        p.tipo,
        p.nombre,
        p.email,
        p.nivelHabilidad,
        p.habilidades,
        m.especialidad,
        m.experiencia,
        m.disponibilidadHoraria,
        p.created_at
    FROM Participante p
    JOIN MentorTecnico m ON p.id = m.id
    WHERE p.id = p_id;
END$$

DROP PROCEDURE IF EXISTS sp_update_mentor$$
CREATE PROCEDURE sp_update_mentor(
    IN p_id INT,
    IN p_nombre VARCHAR(150),
    IN p_email VARCHAR(200),
    IN p_nivelHabilidad ENUM('basico','intermedio','avanzado'),
    IN p_habilidades JSON,
    IN p_especialidad VARCHAR(150),
    IN p_experiencia INT,
    IN p_disponibilidad VARCHAR(150)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; END;
    START TRANSACTION;

    UPDATE Participante
    SET nombre = p_nombre,
        email = p_email,
        nivelHabilidad = p_nivelHabilidad,
        habilidades = p_habilidades
    WHERE id = p_id AND tipo = 'MENTOR_TECNICO';

    UPDATE MentorTecnico
    SET especialidad = p_especialidad,
        experiencia = p_experiencia,
        disponibilidadHoraria = p_disponibilidad
    WHERE id = p_id;

    COMMIT;
    SELECT 1 AS OK;
END$$

DROP PROCEDURE IF EXISTS sp_delete_mentor$$
CREATE PROCEDURE sp_delete_mentor(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; END;
    START TRANSACTION;

    DELETE FROM MentorTecnico WHERE id = p_id;
    DELETE FROM Participante WHERE id = p_id AND tipo = 'MENTOR_TECNICO';

    COMMIT;
    SELECT 1 AS OK;
END$$

DELIMITER ;
