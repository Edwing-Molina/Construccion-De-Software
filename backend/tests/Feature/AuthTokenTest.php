<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class AuthTokenTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Role::create(['name' => 'patient', 'guard_name' => 'web']);
        Role::create(['name' => 'doctor', 'guard_name' => 'web']);
    }

    public function test_login_returns_token(): void
    {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password123'),
        ]);

        $user->assignRole('patient');

        $response = $this->postJson('/api/mobile/login', [
            'email' => 'test@example.com',
            'password' => 'password123',
            'device_name' => 'test_device',
        ]);

        $response->assertStatus(200);
        $response->assertJsonStructure(['token', 'role']);
        $this->assertNotEmpty($response['token']);
    }

    public function test_login_fails_with_wrong_password(): void
    {
        User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password123'),
        ]);

        $response = $this->postJson('/api/mobile/login', [
            'email' => 'test@example.com',
            'password' => 'wrongpassword',
            'device_name' => 'test_device',
        ]);

        $response->assertStatus(422);
    }

    public function test_login_requires_device_name(): void
    {
        User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password123'),
        ]);

        $response = $this->postJson('/api/mobile/login', [
            'email' => 'test@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(422);
    }
}
