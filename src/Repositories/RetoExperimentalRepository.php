<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Entities\RetoExperimental;
use App\Config\Database;
use App\Interfaces\RepositoryInterface;
use PDO;

class RetoExperimentalRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof RetoExperimental) {
            throw new \InvalidArgumentException("Expected instance of RetoExperimental");
        }

        $stmt = $this->db->prepare("CALL sp_crear_reto_experimental(
            :id,
            :titulo,
            :descripcion,
            :complejidad,
            :areas_conocimiento,
            :enfoque_pedagogico
        )");

        $ok = $stmt->execute([
            "id" => (string)$entity->getId(),
            "titulo" => $entity->getTitulo(),
            "descripcion" => $entity->getDescripcion(),
            "complejidad" => $entity->getComplejidad(),
            "areas_conocimiento" => json_encode($entity->getAreasConocimiento(), JSON_UNESCAPED_UNICODE),
            "enfoque_pedagogico" => $entity->getEnfoquePedagogico()
        ]);

        if ($ok) { $stmt->fetch(PDO::FETCH_ASSOC); }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare("CALL sp_obtener_reto_experimental_por_id(:id)");
        $stmt->execute(["id" => (string)$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof RetoExperimental) {
            throw new \InvalidArgumentException("Expected instance of RetoExperimental");
        }

        $stmt = $this->db->prepare("CALL sp_actualizar_reto_experimental(
            :id,
            :titulo,
            :descripcion,
            :complejidad,
            :areas_conocimiento,
            :enfoque_pedagogico
        )");

        $ok = $stmt->execute([
            "id" => (string)$entity->getId(),
            "titulo" => $entity->getTitulo(),
            "descripcion" => $entity->getDescripcion(),
            "complejidad" => $entity->getComplejidad(),
            "areas_conocimiento" => json_encode($entity->getAreasConocimiento(), JSON_UNESCAPED_UNICODE),
            "enfoque_pedagogico" => $entity->getEnfoquePedagogico()
        ]);

        if ($ok) { $stmt->fetch(PDO::FETCH_ASSOC); }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare("CALL sp_eliminar_reto_experimental(:id)");
        $ok = $stmt->execute(["id" => (string)$id]);
        $stmt->closeCursor();
        return $ok;
    }

    public function findAll(): array
    {
        $stmt = $this->db->query("CALL sp_listar_retos_experimentales()");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        $out = [];
        foreach ($rows as $row) {
            $out[] = $this->hydrate($row);
        }
        return $out;
    }

    private function hydrate(array $row): RetoExperimental
    {
        return new RetoExperimental(
            $row['id'],
            $row['titulo'],
            $row['descripcion'],
            $row['complejidad'],
            json_decode($row['areas_conocimiento'] ?? '[]', true),
            $row['enfoque_pedagogico']
        );
    }
}
