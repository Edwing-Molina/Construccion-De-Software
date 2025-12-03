<?php

namespace Tests\Unit\Models;

use App\Models\User;
use App\Models\Doctor;
use App\Models\Patient;
use Tests\TestCase;

class UserModelTest extends TestCase
{
    /**
     * Test user creation with fillable attributes
     */
    public function test_user_can_be_created_with_name_email_password(): void
    {
        $user = User::create([
            'name' => 'Juan Pérez',
            'email' => 'juan@example.com',
            'password' => 'password123',
        ]);

        $this->assertNotNull($user->id);
        $this->assertEquals('Juan Pérez', $user->name);
        $this->assertEquals('juan@example.com', $user->email);
    }

    /**
     * Test password is hashed on creation
     */
    public function test_user_password_is_hashed(): void
    {
        $plainPassword = 'password123';
        $user = User::create([
            'name' => 'Maria García',
            'email' => 'maria@example.com',
            'password' => $plainPassword,
        ]);

        $this->assertNotEquals($plainPassword, $user->password);
    }

    /**
     * Test user password is hidden in serialization
     */
    public function test_user_password_is_hidden_in_array(): void
    {
        $user = User::create([
            'name' => 'Carlos López',
            'email' => 'carlos@example.com',
            'password' => 'password123',
        ]);

        $userArray = $user->toArray();
        $this->assertArrayNotHasKey('password', $userArray);
    }

    /**
     * Test user can have a doctor profile
     */
    public function test_user_can_have_doctor_relationship(): void
    {
        $user = User::create([
            'name' => 'Dr. Rodríguez',
            'email' => 'doctor@example.com',
            'password' => 'password123',
        ]);

        $doctor = Doctor::create([
            'user_id' => $user->id,
        ]);

        $this->assertTrue($user->doctor()->exists());
        $this->assertEquals($doctor->id, $user->doctor->id);
    }

    /**
     * Test user can have a patient profile
     */
    public function test_user_can_have_patient_relationship(): void
    {
        $user = User::create([
            'name' => 'Juan Paciente',
            'email' => 'patient@example.com',
            'password' => 'password123',
        ]);

        $patient = Patient::create([
            'user_id' => $user->id,
            'birth' => '1990-01-15',
            'blood_type' => 'O+',
        ]);

        $this->assertTrue($user->patient()->exists());
        $this->assertEquals($patient->id, $user->patient->id);
    }

    /**
     * Test email is unique
     */
    public function test_user_email_must_be_unique(): void
    {
        User::create([
            'name' => 'Usuario Uno',
            'email' => 'duplicate@example.com',
            'password' => 'password123',
        ]);

        $this->expectException(\Illuminate\Database\QueryException::class);
        User::create([
            'name' => 'Usuario Dos',
            'email' => 'duplicate@example.com',
            'password' => 'password456',
        ]);
    }

    /**
     * Test user email verification timestamp casting
     */
    public function test_user_email_verified_at_is_cast_to_datetime(): void
    {
        $user = User::create([
            'name' => 'Verificado',
            'email' => 'verified@example.com',
            'password' => 'password123',
            'email_verified_at' => now(),
        ]);

        $this->assertInstanceOf(\Carbon\Carbon::class, $user->email_verified_at);
    }

    /**
     * Test user can be updated
     */
    public function test_user_can_be_updated(): void
    {
        $user = User::create([
            'name' => 'Original Name',
            'email' => 'original@example.com',
            'password' => 'password123',
        ]);

        $user->update(['name' => 'Updated Name']);

        $this->assertEquals('Updated Name', $user->fresh()->name);
    }

    /**
     * Test user can be deleted
     */
    public function test_user_can_be_deleted(): void
    {
        $user = User::create([
            'name' => 'Para Borrar',
            'email' => 'delete@example.com',
            'password' => 'password123',
        ]);

        $userId = $user->id;
        $user->delete();

        $this->assertNull(User::find($userId));
    }
}
