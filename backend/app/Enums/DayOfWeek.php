<?php

namespace App\Enums;

enum DayOfWeek: string
{
    case MONDAY = 'Monday';      
    case TUESDAY = 'Tuesday';
    case WEDNESDAY = 'Wednesday';
    case THURSDAY = 'Thursday';
    case FRIDAY = 'Friday';
    case SATURDAY = 'Saturday';
    case SUNDAY = 'Sunday';

    public static function toArray(): array
    {
        return array_column(self::cases(), 'value');
    }
}