<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Entities\Equipo;
use App\Config\Database;
use App\Interfaces\RepositoryInterface;
use PDO;

class EquipoRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Equipo) {
            throw new \InvalidArgumentException("Expected instance of Equipo");
        }

        // 1) Crear equipo
        $stmt = $this->db->prepare("CALL sp_crear_equipo(:id, :nombre, :hackathon_id)");
        $ok = $stmt->execute([
            "id" => (string)$entity->getId(),
            "nombre" => $entity->getNombre(),
            "hackathon_id" => (string)$entity->getHackathonId()
        ]);
        if ($ok) { $stmt->fetch(PDO::FETCH_ASSOC); }
        $stmt->closeCursor();

        if (!$ok) return false;

        // 2) Agregar participantes con el SP dedicado
        $members = $entity->getParticipanteIds();
        foreach ($members as $pid) {
            $stmt2 = $this->db->prepare("CALL sp_agregar_participante_equipo(:equipo_id, :participante_id, :rol)");
            $stmt2->execute([
                "equipo_id" => (string)$entity->getId(),
                "participante_id" => (string)$pid,
                "rol" => 'miembro' // ajusta según tu UI ('líder','mentor',etc.)
            ]);
            $stmt2->fetch(PDO::FETCH_ASSOC);
            $stmt2->closeCursor();
        }

        return true;
    }

    public function findById(int $id): ?object
    {
        // Tu SP retorna desde la vista equipos_con_estadisticas
        $stmt = $this->db->prepare("CALL sp_obtener_equipo_por_id(:id)");
        $stmt->execute(["id" => (string)$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        if (!$row) return null;

        // Nota: la vista no devuelve participanteIds; los pedimos aparte
        $members = $this->getParticipantesIds((string)$row['id']);

        return $this->hydrate($row, $members);
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Equipo) {
            throw new \InvalidArgumentException("Expected instance of Equipo");
        }

        $stmt = $this->db->prepare("CALL sp_actualizar_equipo(:id, :nombre, :hackathon_id)");
        $ok = $stmt->execute([
            "id" => (string)$entity->getId(),
            "nombre" => $entity->getNombre(),
            "hackathon_id" => (string)$entity->getHackathonId()
        ]);
        if ($ok) { $stmt->fetch(PDO::FETCH_ASSOC); }
        $stmt->closeCursor();

        // Si necesitas sincronizar miembros, aquí deberías:
        // - leer actuales
        // - calcular diff
        // - usar INSERT/DELETE con sp_agregar_participante_equipo y (necesitarías) sp_quitar_participante_equipo

        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare("CALL sp_eliminar_equipo(:id)");
        $ok = $stmt->execute(["id" => (string)$id]);
        $stmt->closeCursor();
        return $ok;
    }

    public function findAll(): array
    {
        // Tu SP usa la vista equipos_con_estadisticas
        $stmt = $this->db->query("CALL sp_listar_equipos()");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        $out = [];
        foreach ($rows as $row) {
            $members = $this->getParticipantesIds((string)$row['id']);
            $out[] = $this->hydrate($row, $members);
        }
        return $out;
    }

    private function getParticipantesIds(string $equipoId): array
    {
        $stmt = $this->db->prepare("CALL sp_obtener_participantes_equipo(:equipo_id)");
        $stmt->execute(["equipo_id" => $equipoId]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $stmt->closeCursor();

        return array_map(fn($r) => (string)$r['id'], $rows);
    }

    private function hydrate(array $row, array $participanteIds): Equipo
    {
        return new Equipo(
            $row['id'],
            $row['nombre'],
            (string)$row['hackathon_id'],
            $participanteIds
        );
    }
}
