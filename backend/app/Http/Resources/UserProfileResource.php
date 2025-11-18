<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

final class UserProfileResource extends JsonResource
{
    private bool $showSensitiveData;

    public function __construct($resource, bool $showSensitiveData = true)
    {
        parent::__construct($resource);
        $this->showSensitiveData = $showSensitiveData;
    }

    public function toArray(Request $request): array
    {
        return [
            ...$this->getBasicUserData(),
            ...$this->getPatientDataIfExists(),
            ...$this->getDoctorDataIfExists(),
        ];
    }

    private function getBasicUserData(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
        ];
    }

    private function getPatientDataIfExists(): array
    {
        if (!$this->hasPatientRole()) {
            return [];
        }

        return [
            'patient' => [
                'id' => $this->patient->id,
                'birth_date' => $this->patient->birth_date?->toDateString(),
                'blood_type' => $this->patient->blood_type,
                'gender' => $this->patient->gender ?? null,
                'emergency_contact_name' => $this->patient->emergency_contact_name,
                'emergency_contact_phone' => $this->patient->emergency_contact_phone,
                'nss_number' => $this->when(
                    $this->showSensitiveData,
                    $this->patient->nss_number
                ),
            ],
        ];
    }

    private function getDoctorDataIfExists(): array
    {
        if (!$this->hasDoctorRole()) {
            return [];
        }

        return [
            'doctor' => $this->getBasicDoctorData(),
            'specialties' => $this->getDoctorSpecialties(),
            'clinics' => $this->getDoctorClinics(),
        ];
    }

    
    private function getBasicDoctorData(): array
    {
        return [
            'id' => $this->doctor->id,
            'consultation_fee' => $this->doctor->consultation_fee ?? null,
            'license_number' => $this->when(
                $this->showSensitiveData,
                $this->doctor->license_number
            ),
        ];
    }

    private function getDoctorSpecialties(): array
    {
        if (!$this->doctor->relationLoaded('specialtys')) {
            return [];
        }

        return $this->doctor->specialtys->map(fn($specialty) => [
            'id' => $specialty->id,
            'name' => $specialty->name,
        ])->toArray();
    }

    private function getDoctorClinics(): array
    {
        if (!$this->doctor->relationLoaded('clinics')) {
            return [];
        }

        return $this->doctor->clinics->map(fn($clinic) => [
            'id' => $clinic->id,
            'name' => $clinic->name,
            'address' => $clinic->address,
            'office_number' => $clinic->pivot->office_number ?? null,
        ])->toArray();
    }


    private function hasPatientRole(): bool
    {
        return $this->relationLoaded('patient') && $this->patient !== null;
    }

    private function hasDoctorRole(): bool
    {
        return $this->relationLoaded('doctor') && $this->doctor !== null;
    }
}
