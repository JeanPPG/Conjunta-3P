<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Entities\RetoReal;
use App\Config\Database;
use App\Interfaces\RepositoryInterface;
use PDO;

class RetoRealRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof RetoReal) {
            throw new \InvalidArgumentException("Expected instance of RetoReal");
        }

        $stmt = $this->db->prepare("CALL sp_create_retoreal(
            :titulo,
            :descripcion,
            :complejidad,
            :areasConocimiento,
            :entidadColaboradora
        )");

        $ok = $stmt->execute([
            "titulo" => $entity->getTitulo(),
            "descripcion" => $entity->getDescripcion(),
            "complejidad" => $entity->getComplejidad(),
            "areasConocimiento" => json_encode($entity->getAreasConocimiento(), JSON_UNESCAPED_UNICODE),
            "entidadColaboradora" => $entity->getEntidadColaboradora()
        ]);

        if ($ok) {
            $stmt->fetch(PDO::FETCH_ASSOC);
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare("CALL sp_find_retoreal(:id)");
        $stmt->execute(["id" => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof RetoReal) {
            throw new \InvalidArgumentException("Expected instance of RetoReal");
        }

        $stmt = $this->db->prepare("CALL sp_update_retoreal(
            :id,
            :titulo,
            :descripcion,
            :complejidad,
            :areasConocimiento,
            :entidadColaboradora
        )");

        $ok = $stmt->execute([
            "id" => $entity->getId(),
            "titulo" => $entity->getTitulo(),
            "descripcion" => $entity->getDescripcion(),
            "complejidad" => $entity->getComplejidad(),
            "areasConocimiento" => json_encode($entity->getAreasConocimiento(), JSON_UNESCAPED_UNICODE),
            "entidadColaboradora" => $entity->getEntidadColaboradora()
        ]);

        if ($ok) {
            $stmt->fetch(PDO::FETCH_ASSOC);
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare("CALL sp_delete_retoreal(:id)");
        $ok = $stmt->execute(["id" => $id]);
        $stmt->closeCursor();
        return $ok;
    }

    public function findAll(): array
    {
        $stmt = $this->db->query("CALL sp_retoreal_list()");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        $out = [];
        foreach ($rows as $row) {
            $out[] = $this->hydrate($row);
        }
        return $out;
    }

    private function hydrate(array $row): RetoReal
    {
        return new RetoReal(
            (int)$row['id'],
            $row['titulo'],
            $row['descripcion'],
            $row['complejidad'],
            json_decode($row['areasConocimiento'] ?? '[]', true),
            $row['entidadColaboradora']
        );
    }
}
