<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\User;
use App\Models\Specialty;
use App\Models\Clinic;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\ModelNotFoundException;

final class ProfileService
{

    public function updateUserProfile(User $user, array $validatedData): User
    {
        return DB::transaction(function () use ($user, $validatedData) {
            $this->updateBasicUserInfo($user, $validatedData);
            $this->updatePatientInfoIfExists($user, $validatedData);
            $this->updateDoctorInfoIfExists($user, $validatedData);

            return $user->fresh()->load('patient', 'doctor.specialtys', 'doctor.clinics');
        });
    }

    public function getUserById(int $userId): User
    {
        return User::with(['patient', 'doctor.specialtys', 'doctor.clinics'])
            ->findOrFail($userId);
    }


    private function updateBasicUserInfo(User $user, array $validatedData): void
    {
        $basicFields = ['name', 'phone'];
        $dataToUpdate = array_filter(
            $validatedData,
            fn($key) => in_array($key, $basicFields),
            ARRAY_FILTER_USE_KEY
        );

        if (!empty($dataToUpdate)) {
            $user->update($dataToUpdate);
        }
    }

    private function updatePatientInfoIfExists(User $user, array $validatedData): void
    {
        if (!$user->patient || !isset($validatedData['patient'])) {
            return;
        }

        $user->patient->update($validatedData['patient']);
    }

    private function updateDoctorInfoIfExists(User $user, array $validatedData): void
    {
        if (!$user->doctor) {
            return;
        }

        if (isset($validatedData['doctor'])) {
            $user->doctor->update($validatedData['doctor']);
        }

        if (isset($validatedData['specialty_ids'])) {
            $this->syncDoctorSpecialties($user->doctor, $validatedData['specialty_ids']);
        }

        if (isset($validatedData['clinics'])) {
            $this->syncDoctorClinicsWithOffices($user->doctor, $validatedData['clinics']);
        }
    }


    private function syncDoctorSpecialties($doctor, array $specialtyIds): void
    {
        $validSpecialtyIds = Specialty::whereIn('id', $specialtyIds)
            ->pluck('id')
            ->toArray();

        if (count($validSpecialtyIds) !== count($specialtyIds)) {
            throw new \InvalidArgumentException(
                'Una o más especialidades son inválidas.'
            );
        }

        $doctor->specialtys()->sync($specialtyIds);
    }

    private function syncDoctorClinicsWithOffices($doctor, array $clinicsData): void
    {
        $pivotData = $this->preparePivotDataForClinics($clinicsData);

        if (!empty($pivotData)) {
            $doctor->clinics()->sync($pivotData);
        }
    }

    
    private function preparePivotDataForClinics(array $clinicsData): array
    {
        $pivotData = [];

        foreach ($clinicsData as $clinicInfo) {
            if (!isset($clinicInfo['clinic_id'])) {
                continue;
            }

            $this->ensureClinicExists($clinicInfo['clinic_id']);

            $pivotData[$clinicInfo['clinic_id']] = [
                'office_number' => $clinicInfo['office_number'] ?? null,
            ];
        }

        return $pivotData;
    }


    private function ensureClinicExists(int $clinicId): void
    {
        $clinicExists = Clinic::where('id', $clinicId)->exists();

        if (!$clinicExists) {
            throw new ModelNotFoundException(
                "La clínica con ID {$clinicId} no fue encontrada."
            );
        }
    }
}
