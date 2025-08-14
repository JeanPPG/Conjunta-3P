<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Entities\Estudiante;
use App\Config\Database;
use App\Interfaces\RepositoryInterface;
use PDO;

class EstudianteRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Estudiante) {
            throw new \InvalidArgumentException("Expected instance of Estudiante");
        }

        $stmt = $this->db->prepare("CALL sp_create_estudiante(
            :nombre,
            :email,
            :nivelHabilidad,
            :habilidades,
            :grado,
            :institucion,
            :tiempoDisponibleSemanal
        )");

        $ok = $stmt->execute([
            "nombre" => $entity->getNombre(),
            "email" => $entity->getEmail(),
            "nivelHabilidad" => $entity->getNivelHabilidad(),
            "habilidades" => json_encode($entity->getHabilidades(), JSON_UNESCAPED_UNICODE),
            "grado" => $entity->getGrado(),
            "institucion" => $entity->getIntitucion(),
            "tiempoDisponibleSemanal" => $entity->getTiempoDisponibleSemanal()
        ]);

        if ($ok) {
            $stmt->fetch(PDO::FETCH_ASSOC);
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare("CALL sp_find_estudiante(:id)");
        $stmt->execute(["id" => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Estudiante) {
            throw new \InvalidArgumentException("Expected instance of Estudiante");
        }

        $stmt = $this->db->prepare("CALL sp_update_estudiante(
            :id,
            :nombre,
            :email,
            :nivelHabilidad,
            :habilidades,
            :grado,
            :institucion,
            :tiempoDisponibleSemanal
        )");

        $ok = $stmt->execute([
            "id" => $entity->getId(),
            "nombre" => $entity->getNombre(),
            "email" => $entity->getEmail(),
            "nivelHabilidad" => $entity->getNivelHabilidad(),
            "habilidades" => json_encode($entity->getHabilidades(), JSON_UNESCAPED_UNICODE),
            "grado" => $entity->getGrado(),
            "institucion" => $entity->getIntitucion(),
            "tiempoDisponibleSemanal" => $entity->getTiempoDisponibleSemanal()
        ]);

        if ($ok) {
            $stmt->fetch(PDO::FETCH_ASSOC);
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare("CALL sp_delete_estudiante(:id)");
        $ok = $stmt->execute(["id" => $id]);
        $stmt->closeCursor();
        return $ok;
    }

    public function findAll(): array
    {
        $stmt = $this->db->query("CALL sp_estudiante_list()");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        $out = [];
        foreach ($rows as $row) {
            $out[] = $this->hydrate($row);
        }
        return $out;
    }

    private function hydrate(array $row): Estudiante
    {
        return new Estudiante(
            (int)$row['id'],
            $row['nombre'],
            $row['email'],
            $row['nivelHabilidad'],
            json_decode($row['habilidades'] ?? '[]', true),
            $row['grado'],
            $row['institucion'],
            $row['tiempoDisponibleSemanal']
        );
    }
}
