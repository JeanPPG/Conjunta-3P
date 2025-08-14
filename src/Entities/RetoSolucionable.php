<?php

declare(strict_types=1);

namespace App\Entities;

abstract class RetoSolucionable
{
    protected int $id;
    protected string $titulo;
    protected string $descripcion;
    protected string $complejidad;
    protected array $areasConocimiento;

    function __construct(int $id, string $titulo, string $descripcion, string $complejidad, array $areasConocimiento)
    {
        $this->id = $id;
        $this->titulo = $titulo;
        $this->descripcion = $descripcion;
        $this->complejidad = $complejidad;
        $this->areasConocimiento = $areasConocimiento;
    }

    function getId(): int
    {
        return $this->id;
    }

    function getTitulo(): string
    {
        return $this->titulo;
    }

    function getDescripcion(): string
    {
        return $this->descripcion;
    }

    function getComplejidad(): string
    {
        return $this->complejidad;
    }

    function getAreasConocimiento(): array
    {
        return $this->areasConocimiento;
    }

    function setId(int $id): void
    {
        $this->id = $id;
    }

    function setTitulo(string $titulo): void
    {
        $this->titulo = $titulo;
    }

    function setDescripcion(string $descripcion): void
    {
        $this->descripcion = $descripcion;
    }

    function setComplejidad(string $complejidad): void
    {
        $this->complejidad = $complejidad;
    }

    function setAreasConocimiento(array $areasConocimiento): void
    {
        $this->areasConocimiento = $areasConocimiento;
    }
}

?>