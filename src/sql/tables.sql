-- =========================================================
-- BASE DE DATOS
-- =========================================================
CREATE DATABASE IF NOT EXISTS conjunta3p_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE eduhack_db;

-- =========================================================
-- HACKATHON / EVENTO
-- =========================================================
CREATE TABLE Hackathon (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  codigo        VARCHAR(50) NOT NULL UNIQUE,        -- ej: 'eduhack2025'
  nombre        VARCHAR(150) NOT NULL,
  fechaInicio   DATETIME NOT NULL,
  fechaFin      DATETIME NOT NULL,
  modalidad     ENUM('ONLINE','PRESENCIAL','HIBRIDO') NOT NULL DEFAULT 'HIBRIDO',
  lugar         VARCHAR(150) NULL,
  estado        ENUM('PLANIFICADO','EN_CURSO','FINALIZADO') NOT NULL DEFAULT 'PLANIFICADO',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =========================================================
-- PARTICIPANTE (ABSTRACTA) + SUBTIPOS
-- =========================================================
CREATE TABLE Participante (
  id                 INT AUTO_INCREMENT PRIMARY KEY,
  codigo             VARCHAR(50) NOT NULL UNIQUE,   -- ej: 'estudiante_001', 'mentor_005' (para APIs)
  tipo               ENUM('ESTUDIANTE','MENTOR_TECNICO') NOT NULL,
  nombre             VARCHAR(150) NOT NULL,
  email              VARCHAR(200) NOT NULL UNIQUE,
  nivelHabilidad     ENUM('basico','intermedio','avanzado') NOT NULL,
  habilidades        JSON NULL,                     -- ej: ["JavaScript","UI/UX","Python"]
  created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Estudiante (1:1 con Participante)
CREATE TABLE Estudiante (
  id                        INT PRIMARY KEY,
  grado                     VARCHAR(30) NOT NULL,         -- ej: "11"
  institucion               VARCHAR(150) NOT NULL,
  tiempoDisponibleSemanal   INT NOT NULL,                 -- horas
  CONSTRAINT fk_est_part FOREIGN KEY (id)
    REFERENCES Participante(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Mentor Técnico (1:1 con Participante)
CREATE TABLE MentorTecnico (
  id                    INT PRIMARY KEY,
  especialidad          VARCHAR(150) NOT NULL,
  experiencia           INT NOT NULL,                     -- años
  disponibilidadHoraria VARCHAR(150) NULL,                -- ej: "viernes y sábados"
  CONSTRAINT fk_ment_part FOREIGN KEY (id)
    REFERENCES Participante(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- RETO (ABSTRACTA) + SUBTIPOS
-- =========================================================
CREATE TABLE Reto (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  codigo              VARCHAR(50) NOT NULL UNIQUE,        -- ej: 'reto_101'
  hackathon_id        INT NULL,                           -- reto asociado a un evento (o NULL si es catálogo)
  tipo                ENUM('REAL','EXPERIMENTAL') NOT NULL,
  titulo              VARCHAR(200) NOT NULL,
  descripcion         TEXT NOT NULL,
  complejidad         ENUM('facil','media','dificil') NOT NULL,
  areasConocimiento   JSON NULL,                          -- ej: ["Geolocalización","Mobile","Medioambiente"]
  estado              ENUM('ACTIVO','INACTIVO') NOT NULL DEFAULT 'ACTIVO',
  created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_reto_hack FOREIGN KEY (hackathon_id)
    REFERENCES Hackathon(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Reto Real (1:1 con Reto)
CREATE TABLE RetoReal (
  id                   INT PRIMARY KEY,
  entidadColaboradora  VARCHAR(200) NOT NULL,             -- ONG/empresa
  CONSTRAINT fk_retoreal_reto FOREIGN KEY (id)
    REFERENCES Reto(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Reto Experimental (1:1 con Reto)
CREATE TABLE RetoExperimental (
  id                   INT PRIMARY KEY,
  enfoquePedagogico    VARCHAR(100) NOT NULL,             -- ej: 'STEM','STEAM','ABP', etc.
  CONSTRAINT fk_retoexp_reto FOREIGN KEY (id)
    REFERENCES Reto(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- EQUIPO Y RELACIONES M:N
-- =========================================================
CREATE TABLE Equipo (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  codigo        VARCHAR(50) NOT NULL UNIQUE,              -- ej: 'equipo_501'
  nombre        VARCHAR(150) NOT NULL,
  hackathon_id  INT NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_equipo_hack FOREIGN KEY (hackathon_id)
    REFERENCES Hackathon(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Equipo ↔ Participante (M:N)
CREATE TABLE EquipoParticipante (
  equipo_id        INT NOT NULL,
  participante_id  INT NOT NULL,
  rol              ENUM('ESTUDIANTE','MENTOR_TECNICO') NOT NULL,
  PRIMARY KEY (equipo_id, participante_id),
  CONSTRAINT fk_eqp_eq FOREIGN KEY (equipo_id)
    REFERENCES Equipo(id) ON DELETE CASCADE,
  CONSTRAINT fk_eqp_part FOREIGN KEY (participante_id)
    REFERENCES Participante(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Equipo ↔ Reto (M:N) con estado/avance del reto en el equipo
CREATE TABLE EquipoReto (
  equipo_id     INT NOT NULL,
  reto_id       INT NOT NULL,
  estado        ENUM('pendiente','en_progreso','completado','abandonado') NOT NULL DEFAULT 'pendiente',
  avance        TINYINT UNSIGNED NOT NULL DEFAULT 0,      -- 0..100 (%)
  asignado_en   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (equipo_id, reto_id),
  CONSTRAINT chk_avance_0_100 CHECK (avance BETWEEN 0 AND 100),
  CONSTRAINT fk_eqr_eq FOREIGN KEY (equipo_id)
    REFERENCES Equipo(id) ON DELETE CASCADE,
  CONSTRAINT fk_eqr_reto FOREIGN KEY (reto_id)
    REFERENCES Reto(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- ÍNDICES ÚTILES
-- =========================================================
CREATE INDEX idx_participante_tipo             ON Participante(tipo);
CREATE INDEX idx_participante_nombre           ON Participante(nombre);
CREATE INDEX idx_reto_tipo                     ON Reto(tipo);
CREATE INDEX idx_reto_hackathon                ON Reto(hackathon_id);
CREATE INDEX idx_equipo_hackathon              ON Equipo(hackathon_id);
CREATE INDEX idx_eqret_estado                  ON EquipoReto(estado);
