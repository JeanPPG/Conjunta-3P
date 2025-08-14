<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\MentorTecnicoRepository;
use App\Entities\MentorTecnico;

class MentorTecnicoController
{
    private MentorTecnicoRepository $repo;

    public function __construct()
    {
        $this->repo = new MentorTecnicoRepository();
    }

    public function handle(): void
    {
        header('Content-Type: application/json');
        $method = $_SERVER['REQUEST_METHOD'];

        if ($method === 'GET') {
            if (isset($_GET['id'])) {
                $id = (int)$_GET['id'];
                $mentor = $this->repo->findById($id);
                echo json_encode($mentor ? $this->mentorToArray($mentor) : null, JSON_UNESCAPED_UNICODE);
            } else {
                $list = array_map([$this, 'mentorToArray'], $this->repo->findAll());
                echo json_encode($list, JSON_UNESCAPED_UNICODE);
            }
            return;
        }

        $payload = json_decode(file_get_contents('php://input'), true) ?? [];

        if ($method === 'POST') {
            $nombre   = (string)($payload['nombre'] ?? '');
            $email    = (string)($payload['email'] ?? '');
            $nivel    = (string)($payload['nivel_habilidad'] ?? ($payload['nivelHabilidad'] ?? 'intermedio'));
            $hab      = $payload['habilidades'] ?? [];
            $esp      = (string)($payload['especialidad'] ?? '');
            $exp      = (int)($payload['experiencia'] ?? 0);
            $disp     = (string)($payload['disponibilidad_horaria'] ?? ($payload['disponibilidadHoraria'] ?? ''));

            if ($nombre === '' || $email === '' || $esp === '') {
                http_response_code(400);
                echo json_encode(['error' => 'nombre, email y especialidad son obligatorios'], JSON_UNESCAPED_UNICODE);
                return;
            }
            if (!is_array($hab)) {
                http_response_code(400);
                echo json_encode(['error' => 'habilidades debe ser un arreglo'], JSON_UNESCAPED_UNICODE);
                return;
            }

            // id=0 para creación (lo genera la BD si usas AUTO_INCREMENT)
            $mentor = new MentorTecnico(
                0,
                $nombre,
                $email,
                $nivel,
                $hab,
                $esp,
                $exp,
                $disp
            );

            echo json_encode(['success' => $this->repo->create($mentor)], JSON_UNESCAPED_UNICODE);
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
                echo json_encode(['error' => 'Mentor técnico no encontrado'], JSON_UNESCAPED_UNICODE);
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

            if (isset($payload['especialidad'])) $existing->setEspecialidad((string)$payload['especialidad']);
            if (isset($payload['experiencia'])) $existing->setExperiencia((int)$payload['experiencia']);
            if (isset($payload['disponibilidad_horaria'])) $existing->setDisponibilidadHoraria((string)$payload['disponibilidad_horaria']);
            if (isset($payload['disponibilidadHoraria'])) $existing->setDisponibilidadHoraria((string)$payload['disponibilidadHoraria']);

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

    private function mentorToArray(MentorTecnico $m): array
    {
        return [
            'id' => $m->getId(),
            'nombre' => $m->getNombre(),
            'email' => $m->getEmail(),
            'nivel_habilidad' => $m->getNivelHabilidad(),
            'habilidades' => $m->getHabilidades(),
            'especialidad' => $m->getEspecialidad(),
            'experiencia' => $m->getExperiencia(),
            'disponibilidad_horaria' => $m->getDisponibilidadHoraria()
        ];
    }
}
