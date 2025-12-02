<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;


final class AppointmentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'appointment_id' => $this->id,
            'current_status' => $this->status,
            'status_display_name' => $this->getHumanReadableStatusLabel(),
            'is_cancellable' => $this->canBeCancelledByPatient(),
            

            'patient_details' => $this->when(
                $this->relationLoaded('patient'),
                fn() => [
                    'patient_id' => $this->patient->id,
                    'patient_name' => $this->patient->user?->name,
                ]
            ),
            

            'doctor_details' => [
                'doctor_id' => $this->availableSchedule?->doctor?->id,
                'doctor_name' => $this->availableSchedule?->doctor?->user?->name,
                'doctor_specialties' => $this->when(
                    $this->availableSchedule?->doctor?->relationLoaded('specialties'),
                    fn() => $this->availableSchedule->doctor->specialties->pluck('name')->toArray()
                ),
            ],
            

            'schedule_details' => [
                'schedule_id' => $this->availableSchedule?->id,
                'appointment_date' => $this->availableSchedule?->date,
                'start_time' => $this->availableSchedule?->start_time,
                'end_time' => $this->availableSchedule?->end_time,
                'formatted_datetime_display' => $this->getFormattedDateTimeForDisplay(),
                'is_scheduled_in_future' => $this->isScheduledInFuture(),
            ],
            

            'created_at' => $this->created_at?->toIso8601String(),
            'last_updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }


    private function getHumanReadableStatusLabel(): string
    {
        return match($this->status) {
            'pendiente' => 'Pendiente',
            'completado' => 'Completado',
            'cancelada' => 'Cancelada',
            default => 'Estado Desconocido',
        };
    }


    private function getFormattedDateTimeForDisplay(): ?string
    {
        if (!$this->availableSchedule) {
            return null;
        }

        $appointmentDate = \Carbon\Carbon::parse($this->availableSchedule->date);
        $appointmentTime = $this->availableSchedule->start_time;

        return sprintf(
            '%s a las %s',
            $appointmentDate->format('d/m/Y'),
            substr($appointmentTime, 0, 5)
        );
    }


    private function isScheduledInFuture(): bool
    {
        if (!$this->availableSchedule) {
            return false;
        }

        $scheduledDateTime = \Carbon\Carbon::parse(
            $this->availableSchedule->date . ' ' . $this->availableSchedule->start_time
        );

        return $scheduledDateTime->isFuture();
    }


    private function canBeCancelledByPatient(): bool
    {
        if ($this->isCancelled() || $this->isCompleted()) {
            return false;
        }

        if (!$this->availableSchedule) {
            return false;
        }

        $scheduledDateTime = \Carbon\Carbon::parse(
            $this->availableSchedule->date . ' ' . $this->availableSchedule->start_time
        );

        $hoursUntilScheduledTime = \Carbon\Carbon::now()->diffInHours($scheduledDateTime, false);

        return $hoursUntilScheduledTime >= 24;
    }
}