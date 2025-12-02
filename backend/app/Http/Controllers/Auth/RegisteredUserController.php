<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
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
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:'.User::class],
            'phone' => ['required', 'string', 'max:20', 'unique:'.User::class],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],

        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->string('password')),
        ]);

        $user->assignRole('patient');

        if(!$user->patient){
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
        }else
        {
            Log::info('Patient profile already exists for user:', ['user_id' => $user->id]);
        }


        event(new Registered($user));

        Auth::login($user);

        $token = $user->createToken('auth_token')->plainTextToken;

        $role = $user->roles->first()->name ?? 'patient';

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
            'role' => $role,
        ], 201);
    }
}
