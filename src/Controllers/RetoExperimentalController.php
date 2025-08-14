<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\RetoExperimentalRepository;
use App\Entities\RetoExperimental;

class RetoExperimentalController
{
    private RetoExperimentalRepository $repo;

    public function __construct()
    {
        $this->repo = new RetoExperimentalRepository();
    }

    public function handle(): void
    {
        header('Content-Type: application/json');
        $method = $_SERVER['REQUEST_METHOD'];

        if ($method === 'GET') {
            if (isset($_GET['id'])) {
                $id = (int)$_GET['id'];
                $reto = $this->repo->findById($id);
                echo json_encode($reto ? $this->retoToArray($reto) : null, JSON_UNESCAPED_UNICODE);
            } else {
                $list = array_map([$this, 'retoToArray'], $this->repo->findAll());
                echo json_encode($list, JSON_UNESCAPED_UNICODE);
            }
            return;
        }

        $payload = json_decode(file_get_contents('php://input'), true) ?? [];

        if ($method === 'POST') {
            $titulo   = (string)($payload['titulo'] ?? '');
            $desc     = (string)($payload['descripcion'] ?? '');
            $comp     = (string)($payload['complejidad'] ?? 'media'); // 'facil'|'media'|'dificil'
            $areas    = $payload['areas_conocimiento'] ?? ($payload['areasConocimiento'] ?? []);
            $enfoque  = (string)($payload['enfoque_pedagogico'] ?? ($payload['enfoquePedagogico'] ?? ''));

            if ($titulo === '' || $desc === '' || $enfoque === '') {
                http_response_code(400);
                echo json_encode(['error' => 'titulo, descripcion y enfoque_pedagogico son obligatorios'], JSON_UNESCAPED_UNICODE);
                return;
            }
            if (!is_array($areas)) {
                http_response_code(400);
                echo json_encode(['error' => 'areas_conocimiento debe ser un arreglo'], JSON_UNESCAPED_UNICODE);
                return;
            }

            $reto = new RetoExperimental(
                0,
                $titulo,
                $desc,
                $comp,
                $areas,
                $enfoque
            );

            echo json_encode(['success' => $this->repo->create($reto)], JSON_UNESCAPED_UNICODE);
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
                echo json_encode(['error' => 'Reto experimental no encontrado'], JSON_UNESCAPED_UNICODE);
                return;
            }

            if (isset($payload['titulo'])) $existing->setTitulo((string)$payload['titulo']);
            if (isset($payload['descripcion'])) $existing->setDescripcion((string)$payload['descripcion']);
            if (isset($payload['complejidad'])) $existing->setComplejidad((string)$payload['complejidad']);

            if (isset($payload['areas_conocimiento'])) {
                if (!is_array($payload['areas_conocimiento'])) {
                    http_response_code(400);
                    echo json_encode(['error' => 'areas_conocimiento debe ser un arreglo'], JSON_UNESCAPED_UNICODE);
                    return;
                }
                $existing->setAreasConocimiento($payload['areas_conocimiento']);
            } elseif (isset($payload['areasConocimiento'])) {
                if (!is_array($payload['areasConocimiento'])) {
                    http_response_code(400);
                    echo json_encode(['error' => 'areasConocimiento debe ser un arreglo'], JSON_UNESCAPED_UNICODE);
                    return;
                }
                $existing->setAreasConocimiento($payload['areasConocimiento']);
            }

            if (isset($payload['enfoque_pedagogico'])) {
                $existing->setEnfoquePedagogico((string)$payload['enfoque_pedagogico']);
            } elseif (isset($payload['enfoquePedagogico'])) {
                $existing->setEnfoquePedagogico((string)$payload['enfoquePedagogico']);
            }

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

    private function retoToArray(RetoExperimental $r): array
    {
        return [
            'id' => $r->getId(),
            'titulo' => $r->getTitulo(),
            'descripcion' => $r->getDescripcion(),
            'complejidad' => $r->getComplejidad(),
            'areas_conocimiento' => $r->getAreasConocimiento(),
            'enfoque_pedagogico' => $r->getEnfoquePedagogico()
        ];
    }
}
