<?php
declare(strict_types=1);

namespace App\Entities;

abstract class Participante
{
    protected int $id;
    protected string $nombre;
    protected string $email;
    protected string $nivelHabilidad;
    protected array $habilidades;

    public function __construct(int $id, string $nombre, string $email, string $nivelHabilidad, array $habilidades)
    {
        $this->id = $id;
        $this->nombre = $nombre;
        $this->email = $email;
        $this->nivelHabilidad = $nivelHabilidad;
        $this->habilidades = $habilidades;
    }

    public function getId(): int
    {
        return $this->id;
    }

    public function getNombre(): string
    {
        return $this->nombre;
    }

    public function getEmail(): string
    {
        return $this->email;
    }

    public function getNivelHabilidad(): string
    {
        return $this->nivelHabilidad;
    }

    public function getHabilidades(): array
    {
        return $this->habilidades;
    }

    public function setId(int $id): void
    {
        $this->id = $id;
    }

    public function setNombre(string $nombre): void
    {
        $this->nombre = $nombre;
    }

    public function setEmail(string $email): void
    {
        $this->email = $email;
    }

    public function setNivelHabilidad(string $nivelHabilidad): void
    {
        $this->nivelHabilidad = $nivelHabilidad;
    }

    public function setHabilidades(array $habilidades): void
    {
        $this->habilidades = $habilidades;
    }
}

?>