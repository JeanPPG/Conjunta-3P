<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Entities\MentorTecnico;
use App\Config\Database;
use App\Interfaces\RepositoryInterface;
use PDO;

class MentorTecnicoRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof MentorTecnico) {
            throw new \InvalidArgumentException("Expected instance of MentorTecnico");
        }

        $stmt = $this->db->prepare("CALL sp_crear_mentor_tecnico(
            :id,
            :nombre,
            :email,
            :nivel_habilidad,
            :habilidades,
            :especialidad,
            :experiencia,
            :disponibilidad
        )");

        $ok = $stmt->execute([
            "id" => (string)$entity->getId(),
            "nombre" => $entity->getNombre(),
            "email" => $entity->getEmail(),
            "nivel_habilidad" => $entity->getNivelHabilidad(),
            "habilidades" => json_encode($entity->getHabilidades(), JSON_UNESCAPED_UNICODE),
            "especialidad" => $entity->getEspecialidad(),
            "experiencia" => $entity->getExperiencia(),
            "disponibilidad" => $entity->getDisponibilidadHoraria()
        ]);

        if ($ok) { $stmt->fetch(PDO::FETCH_ASSOC); }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare("CALL sp_obtener_mentor_por_id(:id)");
        $stmt->execute(["id" => (string)$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof MentorTecnico) {
            throw new \InvalidArgumentException("Expected instance of MentorTecnico");
        }

        $stmt = $this->db->prepare("CALL sp_actualizar_mentor_tecnico(
            :id,
            :nombre,
            :email,
            :nivel_habilidad,
            :habilidades,
            :especialidad,
            :experiencia,
            :disponibilidad
        )");

        $ok = $stmt->execute([
            "id" => (string)$entity->getId(),
            "nombre" => $entity->getNombre(),
            "email" => $entity->getEmail(),
            "nivel_habilidad" => $entity->getNivelHabilidad(),
            "habilidades" => json_encode($entity->getHabilidades(), JSON_UNESCAPED_UNICODE),
            "especialidad" => $entity->getEspecialidad(),
            "experiencia" => $entity->getExperiencia(),
            "disponibilidad" => $entity->getDisponibilidadHoraria()
        ]);

        if ($ok) { $stmt->fetch(PDO::FETCH_ASSOC); }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare("CALL sp_eliminar_mentor_tecnico(:id)");
        $ok = $stmt->execute(["id" => (string)$id]);
        $stmt->closeCursor();
        return $ok;
    }

    public function findAll(): array
    {
        $stmt = $this->db->query("CALL sp_listar_mentores()");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        $out = [];
        foreach ($rows as $row) {
            $out[] = $this->hydrate($row);
        }
        return $out;
    }

    private function hydrate(array $row): MentorTecnico
    {
        return new MentorTecnico(
            $row['id'],
            $row['nombre'],
            $row['email'],
            $row['nivel_habilidad'],
            json_decode($row['habilidades'] ?? '[]', true),
            $row['especialidad'],
            (int)$row['experiencia_anos'],
            $row['disponibilidad_horaria']
        );
    }
}
