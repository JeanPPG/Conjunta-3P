<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\EquipoRepository;
use App\Entities\Equipo;

class EquipoController
{
    private EquipoRepository $repo;

    public function __construct()
    {
        $this->repo = new EquipoRepository();
    }

    public function handle(): void
    {
        header('Content-Type: application/json');
        $method = $_SERVER['REQUEST_METHOD'];

        if ($method === 'GET') {
            if (isset($_GET['id'])) {
                $id = (int)$_GET['id'];
                $eq = $this->repo->findById($id);
                echo json_encode($eq ? $this->equipoToArray($eq) : null, JSON_UNESCAPED_UNICODE);
            } else {
                $list = array_map([$this, 'equipoToArray'], $this->repo->findAll());
                echo json_encode($list, JSON_UNESCAPED_UNICODE);
            }
            return;
        }

        $payload = json_decode(file_get_contents('php://input'), true) ?? [];

        if ($method === 'POST') {
            $nombre       = (string)($payload['nombre'] ?? '');
            // Acepta hackathon_id (snake) o hackathonId (camel). Si usas int en BD, cástealo aquí.
            $hackathonId  = $payload['hackathon_id'] ?? ($payload['hackathonId'] ?? null);
            $participantes = $payload['participanteIds'] ?? [];

            if ($nombre === '' || $hackathonId === null) {
                http_response_code(400);
                echo json_encode(['error' => 'nombre y hackathon_id son obligatorios'], JSON_UNESCAPED_UNICODE);
                return;
            }
            if (!is_array($participantes)) {
                http_response_code(400);
                echo json_encode(['error' => 'participanteIds debe ser un arreglo'], JSON_UNESCAPED_UNICODE);
                return;
            }

            // id=0 para creación (si la BD autogenera INT)
            // Nota: tu entidad Equipo define hackathonId como string.
            // Si tu BD lo maneja como INT, conviértelo aquí y luego a string para la entidad.
            $equipo = new Equipo(
                0,
                $nombre,
                (string)((int)$hackathonId),
                array_map('intval', $participantes) // normalizamos a enteros
            );

            echo json_encode(['success' => $this->repo->create($equipo)], JSON_UNESCAPED_UNICODE);
            return;
        }

        if ($method === 'PUT') {
            $id = (int)($payload['id'] ?? 0);
            if ($id <= 0) {
                http_response_code(400);
                echo json_encode(['error' => 'Falta id'], JSON_UNESCAPED_UNICODE);
                return;
            }

            $existing = $this->repo->findById($id);
            if (!$existing) {
                http_response_code(404);
                echo json_encode(['error' => 'Equipo no encontrado'], JSON_UNESCAPED_UNICODE);
                return;
            }

            if (isset($payload['nombre'])) {
                $existing->setNombre((string)$payload['nombre']);
            }

            if (isset($payload['hackathon_id'])) {
                $existing->setHackathonId((string)((int)$payload['hackathon_id']));
            } elseif (isset($payload['hackathonId'])) {
                $existing->setHackathonId((string)((int)$payload['hackathonId']));
            }

            // OJO: en el repo actual, update() solo actualiza datos del equipo (no sincroniza miembros).
            // Si quisieras sincronizar miembros, lo ideal es exponer endpoints específicos para agregar/quitar
            // usando los SP sp_agregar_participante_equipo y (si lo creas) sp_quitar_participante_equipo.
            echo json_encode(['success' => $this->repo->update($existing)], JSON_UNESCAPED_UNICODE);
            return;
        }

        if ($method === 'DELETE') {
            $id = (int)($payload['id'] ?? 0);
            if ($id <= 0) {
                http_response_code(400);
                echo json_encode(['error' => 'Falta id'], JSON_UNESCAPED_UNICODE);
                return;
            }
            echo json_encode(['success' => $this->repo->delete($id)], JSON_UNESCAPED_UNICODE);
            return;
        }

        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed'], JSON_UNESCAPED_UNICODE);
    }

    private function equipoToArray(Equipo $e): array
    {
        return [
            'id' => $e->getId(),
            'nombre' => $e->getNombre(),
            // Tu entidad define hackathonId como string; aquí lo exponemos tal cual.
            'hackathon_id' => $e->getHackathonId(),
            // El repo ya trae los miembros desde sp_obtener_participantes_equipo:
            'participanteIds' => $e->getParticipanteIds()
        ];
    }
}
