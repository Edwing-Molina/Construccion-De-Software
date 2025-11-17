<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\DayOfWeek;
use Illuminate\Database\Eloquent\Model;

class DoctorWorkPattern extends Model
{
    protected $fillable = [
        'doctor_id', 
        'clinic_id', 
        'day_of_week', 
        'start_time_pattern', 
        'end_time_pattern', 
        'slot_duration_minutes', 
        'is_active', 
        'start_date_effective', 
        'end_date_effective'
    ];

    protected $casts = [
        'day_of_week' => DayOfWeek::class, 
        'start_time_pattern' => 'datetime',
        'end_time_pattern' => 'datetime',   
        'is_active' => 'boolean',
        'start_date_effective' => 'date',
        'end_date_effective' => 'date',
    ];

    public function doctor()
    {
        return $this->belongsTo(Doctor::class);
    }

    public function clinic()
    {
        return $this->belongsTo(Clinic::class);
    }

    public function scopeForDoctor($query, $doctorId)
    {
        return $query->where('doctor_id', $doctorId);
    }

    public static function createWorkPattern(array $data)
    {
        // Verificar si ya existe un patrón de trabajo para el mismo día y clínica
        $exists = self::where('doctor_id', $data['doctor_id'])
            ->where('clinic_id', $data['clinic_id'])
            ->where('day_of_week', $data['day_of_week'])
            ->where('is_active', true)
            ->exists();

        if ($exists) {
            throw new \Exception(
                'Ya existe un patrón activo para este día en la misma clínica.'
            );
        }

        // Crear el patrón de trabajo
        return self::create($data);
    }
}
