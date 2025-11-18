<?php

namespace App\Enums;

enum AppointmentStatus: string
{
    case Pendiente = 'pendiente';
    case Completado = 'completado';
    case Cancelada = 'cancelada';

    public static function toArray(): array
    {
        return array_column(self::cases(), 'value');
    }
}