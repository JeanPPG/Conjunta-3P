<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\EstudianteRepository;
use App\Entities\Estudiante;

class EstudianteController
{
    private EstudianteRepository $repo;

    public function __construct()
    {
        $this->repo = new EstudianteRepository();
    }

    public function handle(): void
    {
        header('Content-Type: application/json');
        $method = $_SERVER['REQUEST_METHOD'];

        if ($method === 'GET') {
            if (isset($_GET['id'])) {
                $id = (int)$_GET['id'];
                $est = $this->repo->findById($id);
                echo json_encode($est ? $this->estudianteToArray($est) : null, JSON_UNESCAPED_UNICODE);
            } else {
                $list = array_map([$this, 'estudianteToArray'], $this->repo->findAll());
                echo json_encode($list, JSON_UNESCAPED_UNICODE);
            }
            return;
        }

        $payload = json_decode(file_get_contents('php://input'), true) ?? [];

        if ($method === 'POST') {
            // Campos aceptados (con tolerancia a snake/camel case)
            $nombre  = (string)($payload['nombre'] ?? '');
            $email   = (string)($payload['email'] ?? '');
            $nivel   = (string)($payload['nivel_habilidad'] ?? ($payload['nivelHabilidad'] ?? 'intermedio'));
            $hab     = $payload['habilidades'] ?? [];
            $grado   = (string)($payload['grado'] ?? '');
            // La entidad actual usa "intitucion" (con t). Aceptamos ambas y pasamos a ese setter.
            $instit  = (string)($payload['institucion'] ?? ($payload['intitucion'] ?? ''));
            // La entidad actual define tiempoDisponibleSemanal como string
            $tiempo  = (string)($payload['tiempo_disponible_semanal'] ?? ($payload['tiempoDisponibleSemanal'] ?? '0'));

            if (!is_array($hab)) {
                http_response_code(400);
                echo json_encode(['error' => 'habilidades debe ser un arreglo'], JSON_UNESCAPED_UNICODE);
                return;
            }
            if ($nombre === '' || $email === '') {
                http_response_code(400);
                echo json_encode(['error' => 'nombre y email son obligatorios'], JSON_UNESCAPED_UNICODE);
                return;
            }

            // Para crear, usamos id=0 (tu repositorio/SP debe generar el id real en BD)
            $estudiante = new Estudiante(
                0,
                $nombre,
                $email,
                $nivel,
                $hab,
                $grado,
                $instit,
                $tiempo
            );

            echo json_encode(['success' => $this->repo->create($estudiante)], JSON_UNESCAPED_UNICODE);
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
                echo json_encode(['error' => 'Estudiante no encontrado'], JSON_UNESCAPED_UNICODE);
                return;
            }

            if (isset($payload['nombre'])) $existing->setNombre((string)$payload['nombre']);
            if (isset($payload['email'])) $existing->setEmail((string)$payload['email']);
            if (isset($payload['nivel_habilidad'])) $existing->setNivelHabilidad((string)$payload['nivel_habilidad']);
            if (isset($payload['nivelHabilidad'])) $existing->setNivelHabilidad((string)$payload['nivelHabilidad']);

            if (isset($payload['habilidades'])) {
                if (!is_array($payload['habilidades'])) {
                    http_response_code(400);
                    echo json_encode(['error' => 'habilidades debe ser un arreglo'], JSON_UNESCAPED_UNICODE);
                    return;
                }
                $existing->setHabilidades($payload['habilidades']);
            }

            if (isset($payload['grado'])) $existing->setGrado((string)$payload['grado']);

            if (isset($payload['institucion'])) {
                $existing->setIntitucion((string)$payload['institucion']); // coincide con tu entidad actual
            } elseif (isset($payload['intitucion'])) {
                $existing->setIntitucion((string)$payload['intitucion']);
            }

            if (isset($payload['tiempo_disponible_semanal'])) {
                $existing->setTiempoDisponibleSemanal((string)$payload['tiempo_disponible_semanal']);
            } elseif (isset($payload['tiempoDisponibleSemanal'])) {
                $existing->setTiempoDisponibleSemanal((string)$payload['tiempoDisponibleSemanal']);
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

    private function estudianteToArray(Estudiante $e): array
    {
        return [
            'id' => $e->getId(),
            'nombre' => $e->getNombre(),
            'email' => $e->getEmail(),
            'nivel_habilidad' => $e->getNivelHabilidad(),
            'habilidades' => $e->getHabilidades(),
            'grado' => $e->getGrado(),
            // Mantengo "intitucion" porque así está en tu entidad actual
            'institucion' => $e->getIntitucion(),
            'tiempo_disponible_semanal' => $e->getTiempoDisponibleSemanal()
        ];
    }
}
