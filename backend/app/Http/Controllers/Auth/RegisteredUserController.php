<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Clinic;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

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
            
            $clinic = Clinic::firstOrCreate(
                ['name' => $request->clinica],
                [
                    'name' => $request->clinica,
                    'address' => 'Por definir',
                ]
            );

            
            $user->assignRole('doctor');

            
            $doctor = $user->doctor()->create([
                'user_id' => $user->id,
                'description' => $request->cedula,
                'license_number' => 'temp_' . time(),
                'profile_picture_url' => '',
                'is_active' => true,
            ]);

            
            $doctor->clinics()->attach($clinic->id);
        } else {
           
            $user->assignRole('patient');

            if (!$user->patient) {
                $patient = $user->patient()->create([
                    'user_id' => $user->id,
                    'birth' => null,
                    'gender' => null,
                    'blood_type' => null,
                    'emergency_contact_name' => null,
                    'emergency_contact_phone' => null,
                    'nss_number' => null,
                ]);
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
