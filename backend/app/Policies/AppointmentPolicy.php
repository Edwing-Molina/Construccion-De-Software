<?php

namespace App\Policies;

use App\Models\Appointment;
use App\Models\User;
use Illuminate\Auth\Access\Response;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class AppointmentPolicy
{
    public function viewAnyAsDoctor(User $user): Response
        {
            if (!$user->hasRole('doctor')) {
                Log::info("El usuario no tiene el rol de doctor: " . $user->id);
                return Response::deny('No estás autorizado para ver citas de doctor.');
            }

            if (!$user->doctor) {
                Log::info("El usuario no tiene un perfil de doctor asociado: " . $user->id);
                return Response::deny('No tienes un perfil de doctor asociado.');
            }

            return Response::allow();
        }

        
    public function complete(User $user, Appointment $appointment)
    {
        return $user->doctor &&
            $appointment->availableSchedule &&
            $appointment->availableSchedule->doctor_id === $user->doctor->id;
    }

}
