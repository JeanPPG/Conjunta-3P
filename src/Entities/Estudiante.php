<?php

declare(strict_types=1);

namespace App\Entities;

class Estudiante extends Participante
{
    private string $grado;
    private string $intitucion;
    private string $tiempoDisponibleSemanal;

    public function __construct(
        int $id,
        string $nombre,
        string $email,
        string $nivelHabilidad,
        array $habilidades,
        string $grado,
        string $intitucion,
        string $tiempoDisponibleSemanal
    ) {
        parent::__construct($id, $nombre, $email, $nivelHabilidad, $habilidades);
        $this->grado = $grado;
        $this->intitucion = $intitucion;
        $this->tiempoDisponibleSemanal = $tiempoDisponibleSemanal;
    }

    public function getGrado(): string
    {
        return $this->grado;
    }

    public function getIntitucion(): string
    {
        return $this->intitucion;
    }

    public function getTiempoDisponibleSemanal(): string
    {
        return $this->tiempoDisponibleSemanal;
    }

    public function setGrado(string $grado): void
    {
        $this->grado = $grado;
    }

    public function setIntitucion(string $intitucion): void
    {
        $this->intitucion = $intitucion;
    }

    public function setTiempoDisponibleSemanal(string $tiempoDisponibleSemanal): void
    {
        $this->tiempoDisponibleSemanal = $tiempoDisponibleSemanal;
    }
}

?>