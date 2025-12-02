<?php

namespace App\Enums;


enum AppointmentStatus: string
{
    case Pendiente = 'pendiente';
    case Completado = 'completado';
    case Cancelada = 'cancelada';

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }

    public static function isValid(string $status): bool
    {
        return in_array($status, self::values(), true);
    }
        public static function toArray(): array
    {
        return array_column(self::cases(), 'value');
    }
}
