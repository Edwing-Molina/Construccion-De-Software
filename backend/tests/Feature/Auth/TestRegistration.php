<?php

namespace Tests\Feature\Auth;

use Tests\TestCase;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

class TestRegistration extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        // Ejecutar el seeder de roles antes de cada test
        $this->artisan('db:seed', ['--class' => 'RolesAndPermissionsSeeder']);
    }

    public function test_can_register_patient(): void
    {
        $userData = [
            'name' => 'Test Patient',
            'email' => 'testpatient@example.com',
            'phone' => '9999999999',
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
            'role' => 'patient',
        ];

        $response = $this->postJson('/api/register', $userData);

        $response->assertStatus(201);
        $response->assertJsonStructure(['user', 'token', 'role']);

        // Verificar que el usuario se guardó en la BD
        $this->assertDatabaseHas('users', [
            'email' => 'testpatient@example.com',
            'name' => 'Test Patient',
        ]);

        $user = User::where('email', 'testpatient@example.com')->first();
        $this->assertNotNull($user);
        $this->assertTrue($user->hasRole('patient'));
    }

    public function test_can_register_doctor(): void
    {
        $userData = [
            'name' => 'Test Doctor',
            'email' => 'testdoctor@example.com',
            'phone' => '8888888888',
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
            'role' => 'doctor',
            'cedula' => 'DOC12345',
            'clinica' => 'Clínica Test',
        ];

        $response = $this->postJson('/api/register', $userData);

        $response->assertStatus(201);
        $response->assertJsonStructure(['user', 'token', 'role']);

        // Verificar que el usuario se guardó en la BD
        $this->assertDatabaseHas('users', [
            'email' => 'testdoctor@example.com',
            'name' => 'Test Doctor',
        ]);

        $user = User::where('email', 'testdoctor@example.com')->first();
        $this->assertNotNull($user);
        $this->assertTrue($user->hasRole('doctor'));
    }
}
