<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    protected $fillable = [
        'doctor_id',
        'patient_id',
        'appointment_date',
        'status',
    ];

    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }

    public function doctor()
    {
        return $this->hasOneThrough(
            Doctor::class,
            AvailableSchedule::class,
            'id', 
            'id', 
            'available_schedule_id', 
            'doctor_id'
        );
    }

    public function availableSchedule()
    {
        return $this->belongsTo(AvailableSchedule::class); 
    }

    public function scopeFilterByStatus($query, $status)
    {
        if ($status) {
            $query->where('status', $status);
        }

        return $query;
    }

    public function scopeFilterByDoctor($query, $doctorId)
    {
        if ($doctorId) {
            $query->whereHas(
                'availableSchedule',
                function ($q) use ($doctorId) {
                    $q->where('doctor_id', $doctorId);
                }
            );
        }

        return $query;
    }

    public function scopeFilterBySpecialty($query, $specialtyId)
    {
        if ($specialtyId) {
            $query->whereHas(
                'availableSchedule.doctor.specialtys',
                function ($q) use ($specialtyId) {
                    $q->where('id', $specialtyId);
                }
            );
        }

        return $query;
    }

    public function scopeFilterByDateRange($query, $fromDate, $toDate)
    {
        if ($fromDate) {
            $query->whereDate('available_schedules.date', '>=', $fromDate);
        }

        if ($toDate) {
            $query->whereDate('available_schedules.date', '<=', $toDate);
        }

        return $query;
    }
}
