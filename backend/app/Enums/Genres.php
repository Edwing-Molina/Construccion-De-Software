<?php

namespace App\Enums;

enum Genres: string
{
    case Masculino = 'masculino';
    case Femenino = 'femenino';
    case Prefiero_no_decirlo = 'prefiero no decirlo';

    public static function toArray(): array
    {
        return array_column(self::cases(), 'value');
    }
}
