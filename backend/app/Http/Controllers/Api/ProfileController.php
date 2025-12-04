<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Clinic;
use App\Models\User;

class ProfileController extends Controller
{
    
    public function show(Request $request)
    {
        $user = $request->user();

        $user->load('patient', 'doctor.specialties', 'doctor.clinics');
        
        $userData = $user->toArray();
        
        
        if ($user->doctor) {
            $userData['specialties'] = $user->doctor->specialties()->get()->map(function ($specialty) {
                return [
                    'id' => $specialty->id,
                    'name' => $specialty->name,
                ];
            });
            
            
            $userData['clinics'] = $user->doctor->clinics()->get()->map(function ($clinic) {
                return [
                    'id' => $clinic->id,
                    'name' => $clinic->name,
                    'address' => $clinic->address,
                    'office_number' => $clinic->pivot->office_number,
                ];
            });
        }

        

        return response()->json([
            'message' => 'Perfil de usuario recuperado exitosamente.',
            'data' => $userData
        ], 200);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request)
    {
        $user = $request->user();

        
        $updateData = [];
        if ($request->has('name') && $request->input('name') !== null) {
            $updateData['name'] = $request->input('name');
        }
        if ($request->has('phone') && $request->input('phone') !== null) {
            $updateData['phone'] = $request->input('phone');
        }

        if (!empty($updateData)) {
            $user->update($updateData);
        }

        if ($user->patient) {
            $patientData = $request->input('patient', []);

            if (isset($patientData['gender']) && !in_array($patientData['gender'], \App\Enums\Genres::toArray())) {
                return response()->json([
                    'message' => 'El género proporcionado no es válido.',
                ], 422);
            }

            if (isset($patientData['gender'])) {
                $user->patient->gender = $patientData['gender'];
            }

            $user->patient->update($patientData);
        }

        if ($user->doctor) {
            $doctorData = $request->input('doctor', []);
            $user->doctor->update($doctorData);

            if ($request->has('specialty_ids')) {
                $specialtyIds = $request->input('specialty_ids');
                

                $validSpecialties = \App\Models\Specialty::whereIn('id', $specialtyIds)->pluck('id')->toArray();

                if (count($validSpecialties) !== count($specialtyIds)) {
                    return response()->json([
                        'message' => 'Una o mas especialidades invalidas.',
                    ], 422);
                }

                $user->doctor->specialties()->sync($specialtyIds);
            }

            
            $clinicsData = $request->input('clinics', $doctorData['clinics'] ?? []);
            
            if (!empty($clinicsData)) {
                $syncData = [];

                foreach ($clinicsData as $clinicData) {
                    if (isset($clinicData['clinic_id'])) {
                        $clinic = Clinic::find($clinicData['clinic_id']);
                        if (!$clinic) {
                            return response()->json([
                                'message' => 'Clínica con ID ' . $clinicData['clinic_id'] . ' no encontrada.',
                            ], 422);
                        }

                        $syncData[$clinicData['clinic_id']] = [
                            'office_number' => $clinicData['office_number'] ?? null
                        ];
                    }
                }

                if (!empty($syncData)) {
                    $user->doctor->clinics()->sync($syncData);
                }
            }
        }

        
        $user->load('patient', 'doctor.specialties', 'doctor.clinics');
        $userData = $user->toArray();
        
        
        if ($user->doctor) {
            $userData['specialties'] = $user->doctor->specialties()->get()->map(function ($specialty) {
                return [
                    'id' => $specialty->id,
                    'name' => $specialty->name,
                ];
            });
            
            
            $userData['clinics'] = $user->doctor->clinics()->get()->map(function ($clinic) {
                return [
                    'id' => $clinic->id,
                    'name' => $clinic->name,
                    'address' => $clinic->address,
                    'office_number' => $clinic->pivot->office_number,
                ];
            });
        }

        return response()->json([
            'message' => 'Perfil de usuario actualizado.',
            'data' => $userData,
        ], 200);
    }


    public function showOtherUser($id)
    {
        $user = User::with(['patient', 'doctor.specialties', 'doctor.clinics'])->findOrFail($id);

        $userData = $user->toArray();
        
        if ($user->doctor) {
            
            unset($userData['doctor']['license_number']);
            
            $userData['specialties'] = $user->doctor->specialties()->get()->map(function ($specialty) {
                return [
                    'id' => $specialty->id,
                    'name' => $specialty->name,
                ];
            });
            
            
            $userData['clinics'] = $user->doctor->clinics()->get()->map(function ($clinic) {
                return [
                    'id' => $clinic->id,
                    'name' => $clinic->name,
                    'address' => $clinic->address,
                    'office_number' => $clinic->pivot->office_number,
                ];
            });
        }

        return response()->json([
            'message' => 'User profile retrieved successfully.',
            'data' => $userData,
        ], 200);
    }
}
