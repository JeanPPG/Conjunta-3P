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

        $stmt = $this->db->prepare("CALL sp_crear_reto_real(
            :id,
            :titulo,
            :descripcion,
            :complejidad,
            :areas_conocimiento,
            :entidad_colaboradora
        )");

        $ok = $stmt->execute([
            "id" => (string)$entity->getId(),
            "titulo" => $entity->getTitulo(),
            "descripcion" => $entity->getDescripcion(),
            "complejidad" => $entity->getComplejidad(),
            "areas_conocimiento" => json_encode($entity->getAreasConocimiento(), JSON_UNESCAPED_UNICODE),
            "entidad_colaboradora" => $entity->getEntidadColaboradora()
        ]);

        if ($ok) { $stmt->fetch(PDO::FETCH_ASSOC); }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare("CALL sp_obtener_reto_real_por_id(:id)");
        $stmt->execute(["id" => (string)$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof RetoReal) {
            throw new \InvalidArgumentException("Expected instance of RetoReal");
        }

        $stmt = $this->db->prepare("CALL sp_actualizar_reto_real(
            :id,
            :titulo,
            :descripcion,
            :complejidad,
            :areas_conocimiento,
            :entidad_colaboradora
        )");

        $ok = $stmt->execute([
            "id" => (string)$entity->getId(),
            "titulo" => $entity->getTitulo(),
            "descripcion" => $entity->getDescripcion(),
            "complejidad" => $entity->getComplejidad(),
            "areas_conocimiento" => json_encode($entity->getAreasConocimiento(), JSON_UNESCAPED_UNICODE),
            "entidad_colaboradora" => $entity->getEntidadColaboradora()
        ]);

        if ($ok) { $stmt->fetch(PDO::FETCH_ASSOC); }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare("CALL sp_eliminar_reto_real(:id)");
        $ok = $stmt->execute(["id" => (string)$id]);
        $stmt->closeCursor();
        return $ok;
    }

    public function findAll(): array
    {
        $stmt = $this->db->query("CALL sp_listar_retos_reales()");
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
            $row['id'],
            $row['titulo'],
            $row['descripcion'],
            $row['complejidad'],
            json_decode($row['areas_conocimiento'] ?? '[]', true),
            $row['entidad_colaboradora']
        );
    }
}
