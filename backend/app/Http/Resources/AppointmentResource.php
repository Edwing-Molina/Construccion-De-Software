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
            'id' => $this->id,
            'patient_id' => $this->patient_id ?? $this->patient?->id,
            'appointment_date' => $this->availableSchedule?->date,
            'status' => $this->status,
            
            'patient' => $this->when(
                $this->relationLoaded('patient'),
                fn() => [
                    'id' => $this->patient->id,
                    'name' => $this->patient->user?->name,
                ]
            ),
            
            'doctor' => $this->when(
                $this->availableSchedule?->doctor,
                fn() => [
                    'id' => $this->availableSchedule->doctor->id,
                    'name' => $this->availableSchedule->doctor->user?->name,
                    'specialties' => $this->availableSchedule->doctor->specialties->pluck('name')->toArray(),
                ]
            ),
            
            'available_schedule' => $this->when(
                $this->relationLoaded('availableSchedule'),
                fn() => [
                    'id' => $this->availableSchedule?->id,
                    'date' => $this->availableSchedule?->date,
                    'start_time' => $this->availableSchedule?->start_time,
                    'end_time' => $this->availableSchedule?->end_time,
                ]
            ),
        ];
    }
}