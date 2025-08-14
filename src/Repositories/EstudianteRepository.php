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

        $stmt = $this->db->prepare("CALL sp_crear_estudiante(
            :id,
            :nombre,
            :email,
            :nivel_habilidad,
            :habilidades,
            :grado,
            :institucion,
            :tiempo_disponible
        )");

        $ok = $stmt->execute([
            "id" => (string)$entity->getId(),
            "nombre" => $entity->getNombre(),
            "email" => $entity->getEmail(),
            "nivel_habilidad" => $entity->getNivelHabilidad(), // 'principiante'|'intermedio'|'avanzado'
            "habilidades" => json_encode($entity->getHabilidades(), JSON_UNESCAPED_UNICODE),
            "grado" => $entity->getGrado(),
            "institucion" => $entity->getIntitucion(), // <-- renombra a getInstitucion() en la entidad
            "tiempo_disponible" => (int)$entity->getTiempoDisponibleSemanal() // <-- cambia a int en entidad
        ]);

        if ($ok) { $stmt->fetch(PDO::FETCH_ASSOC); }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare("CALL sp_obtener_estudiante_por_id(:id)");
        $stmt->execute(["id" => (string)$id]); // si cambias entidad a string, adapta la firma a string
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Estudiante) {
            throw new \InvalidArgumentException("Expected instance of Estudiante");
        }

        $stmt = $this->db->prepare("CALL sp_actualizar_estudiante(
            :id,
            :nombre,
            :email,
            :nivel_habilidad,
            :habilidades,
            :grado,
            :institucion,
            :tiempo_disponible
        )");

        $ok = $stmt->execute([
            "id" => (string)$entity->getId(),
            "nombre" => $entity->getNombre(),
            "email" => $entity->getEmail(),
            "nivel_habilidad" => $entity->getNivelHabilidad(),
            "habilidades" => json_encode($entity->getHabilidades(), JSON_UNESCAPED_UNICODE),
            "grado" => $entity->getGrado(),
            "institucion" => $entity->getIntitucion(),
            "tiempo_disponible" => (int)$entity->getTiempoDisponibleSemanal()
        ]);

        if ($ok) { $stmt->fetch(PDO::FETCH_ASSOC); }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare("CALL sp_eliminar_estudiante(:id)");
        $ok = $stmt->execute(["id" => (string)$id]);
        $stmt->closeCursor();
        return $ok;
    }

    public function findAll(): array
    {
        $stmt = $this->db->query("CALL sp_listar_estudiantes()");
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
            $row['id'],                      // <-- cambia entidad a string $id
            $row['nombre'],
            $row['email'],
            $row['nivel_habilidad'],
            json_decode($row['habilidades'] ?? '[]', true),
            $row['grado'],
            $row['institucion'],                    // <-- corrige nombre en entidad (get/setInstitucion)
            (string)$row['tiempo_disponible_semanal'] // <-- cambia en entidad a int; aquí puedes castear a int
        );
    }
}
