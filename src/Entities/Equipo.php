<?php

declare(strict_types=1);

namespace App\Entities;

class Equipo {
    private int $id;
    private string $nombre;
    private string $hackathonId;
    private array $participanteIds;

    public function __construct(int $id, string $nombre, string $hackathonId, array $participanteIds) {
        $this->id = $id;
        $this->nombre = $nombre;
        $this->hackathonId = $hackathonId;
        $this->participanteIds = $participanteIds;
    }

    public function getId(): int {
        return $this->id;
    }

    public function getNombre(): string {
        return $this->nombre;
    }

    public function getHackathonId(): string {
        return $this->hackathonId;
    }

    public function getParticipanteIds(): array {
        return $this->participanteIds;
    }

    public function setId(int $id): void {
        $this->id = $id;
    }

    public function setNombre(string $nombre): void {
        $this->nombre = $nombre;
    }

    public function setHackathonId(string $hackathonId): void {
        $this->hackathonId = $hackathonId;
    }

    public function setParticipanteIds(array $participanteIds): void {
        $this->participanteIds = $participanteIds;
    }
}