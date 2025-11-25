<?php

namespace App\Models;

use App\Enums\AppointmentStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;

class Appointment extends Model
{
    protected $fillable = [
        'patient_id',
        'available_schedule_id',
        'status',
    ];

    protected $casts = [
        'status' => AppointmentStatus::class,
    ];


    public function patient()
    {
        return $this->belongsTo(Patient::class);
    }

    public function availableSchedule()
    {
        return $this->belongsTo(AvailableSchedule::class);
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

    public function scopeFilterByStatus(Builder $query, ?string $status): Builder
    {
        if (!$status || !AppointmentStatus::isValid($status)) {
            return $query;
        }

        return $query->where('status', $status);
    }

    public function scopeFilterByDoctor(Builder $query, ?int $doctorId): Builder
    {
        if (!$doctorId) {
            return $query;
        }

        return $query->whereHas('availableSchedule', function ($q) use ($doctorId) {
            $q->where('doctor_id', $doctorId);
        });
    }

    public function scopeFilterBySpecialty(Builder $query, ?int $specialtyId): Builder
    {
        if (!$specialtyId) {
            return $query;
        }

        return $query->whereHas('availableSchedule.doctor.specialties', function ($q) use ($specialtyId) {
            $q->where('id', $specialtyId);
        });
    }

    public function scopeFilterByDateRange(Builder $query, ?string $fromDate, ?string $toDate): Builder
    {
        return $query->whereHas('availableSchedule', function ($schedule) use ($fromDate, $toDate) {

            if ($fromDate) {
                $schedule->whereDate('date', '>=', $fromDate);
            }

            if ($toDate) {
                $schedule->whereDate('date', '<=', $toDate);
            }
        });
    }
}
