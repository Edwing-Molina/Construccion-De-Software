<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Clinic;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\Rules;

class RegisteredUserController extends Controller
{
    /**
     * Procesar solicitud de registros.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function store(Request $request): JsonResponse
    {
        $role = $request->input('role', 'patient');
        
        $rules = [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:'.User::class],
            'phone' => ['nullable', 'string', 'max:20', 'unique:'.User::class],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ];

        // Validaciones adicionales para doctores
        if ($role === 'doctor') {
            $rules['cedula'] = ['required', 'string', 'max:50', 'unique:doctors,description'];
            $rules['clinica'] = ['required', 'string', 'max:255'];
        }

        $request->validate($rules);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->string('password')),
        ]);

        if ($role === 'doctor') {
            // Crear o buscar clínica
            $clinic = Clinic::firstOrCreate(
                ['name' => $request->clinica],
                [
                    'name' => $request->clinica,
                    'address' => 'Por definir',
                ]
            );

            // Asignar rol de doctor
            $user->assignRole('doctor');

            // Crear perfil de doctor
            Log::info('Creating doctor profile for user:', [
                'user_id' => $user->id,
                'clinic_id' => $clinic->id,
                'cedula' => $request->cedula
            ]);
            
            $doctor = $user->doctor()->create([
                'user_id' => $user->id,
                'description' => $request->cedula,
                'license_number' => 'temp_' . time(),
                'profile_picture_url' => '',
                'is_active' => true,
            ]);

            // Asociar clínica al doctor
            $doctor->clinics()->attach($clinic->id);
        } else {
            // Asignar rol de paciente
            $user->assignRole('patient');

            if (!$user->patient) {
                Log::info('Creating patient profile for user:', ['user_id' => $user->id]);
                $patient = $user->patient()->create([
                    'user_id' => $user->id,
                    'birth' => null,
                    'gender' => null,
                    'blood_type' => null,
                    'emergency_contact_name' => null,
                    'emergency_contact_phone' => null,
                    'nss_number' => null,
                ]);
            } else {
                Log::info('Patient profile already exists for user:', ['user_id' => $user->id]);
            }
        }

        event(new Registered($user));

        Auth::login($user);

        $token = $user->createToken('auth_token')->plainTextToken;

        $userRole = $user->roles->first()->name ?? 'patient';

        return response()->json([
            'message' => 'Usuario registrado exitosamente',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'created_at' => $user->created_at,
                'updated_at' => $user->updated_at,
            ],
            'token' => $token,
            'role' => $userRole,
        ], 201);
    }
}
