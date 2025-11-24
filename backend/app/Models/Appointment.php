<?php

declare(strict_types=1);

namespace App\Models;

use App\Enums\AppointmentStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Builder;

final class Appointment extends Model
{
    use HasFactory;

    protected $fillable = [
        'patient_id',
        'available_schedule_id',
        'status',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];


    public function patient(): BelongsTo
    {
        return $this->belongsTo(Patient::class);
    }

    public function availableSchedule(): BelongsTo
    {
        return $this->belongsTo(AvailableSchedule::class);
    }


    public function scopeApplyStatusFilter(Builder $query, ?string $statusValue): Builder
    {
        if (empty($statusValue)) {
            return $query;
        }

        return $query->where('status', $statusValue);
    }

    public function scopeApplyDoctorFilter(Builder $query, ?int $doctorIdentifier): Builder
    {
        if (empty($doctorIdentifier)) {
            return $query;
        }

        return $query->whereHas('availableSchedule', function (Builder $scheduleQuery) use ($doctorIdentifier) {
            $scheduleQuery->where('doctor_id', $doctorIdentifier);
        });
    }

    public function scopeApplySpecialtyFilter(Builder $query, ?int $specialtyIdentifier): Builder
    {
        if (empty($specialtyIdentifier)) {
            return $query;
        }

        return $query->whereHas('availableSchedule.doctor.specialties', function (Builder $specialtyQuery) use ($specialtyIdentifier) {
            $specialtyQuery->where('specialties.id', $specialtyIdentifier);
        });
    }

    public function scopeApplyDateRangeFilter(Builder $query, ?string $startDate, ?string $endDate): Builder
    {
        if (empty($startDate) && empty($endDate)) {
            return $query;
        }

        return $query->whereHas('availableSchedule', function (Builder $scheduleQuery) use ($startDate, $endDate) {
            if ($startDate) {
                $scheduleQuery->whereDate('date', '>=', $startDate);
            }
            if ($endDate) {
                $scheduleQuery->whereDate('date', '<=', $endDate);
            }
        });
    }

    public function scopeOnlyUpcomingAppointments(Builder $query): Builder
    {
        return $query->whereHas('availableSchedule', function (Builder $scheduleQuery) {
            $scheduleQuery->whereDate('date', '>=', now()->toDateString());
        })->where('status', '!=', AppointmentStatus::Cancelada->value);
    }

    public function scopeOnlyPastAppointments(Builder $query): Builder
    {
        return $query->whereHas('availableSchedule', function (Builder $scheduleQuery) {
            $scheduleQuery->whereDate('date', '<', now()->toDateString());
        });
    }


    public function markAsCancelled(): bool
    {
        return $this->update(['status' => AppointmentStatus::Cancelada->value]);
    }

    public function markAsCompleted(): bool
    {
        return $this->update(['status' => AppointmentStatus::Completado->value]);
    }

    public function isPending(): bool
    {
        return $this->status === AppointmentStatus::Pendiente->value;
    }

    public function isCancelled(): bool
    {
        return $this->status === AppointmentStatus::Cancelada->value;
    }

    public function isCompleted(): bool
    {
        return $this->status === AppointmentStatus::Completado->value;
    }
}
