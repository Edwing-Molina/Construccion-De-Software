<?php

namespace Tests\Unit\Models;

use App\Models\User;
use App\Models\Doctor;
use App\Models\Patient;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserModelTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_be_created_with_name_email_password(): void
    {
        $user = User::factory()->create([
            'name' => 'Juan Pérez',
            'email' => 'juan@example.com',
        ]);

        $this->assertNotNull($user->id);
        $this->assertEquals('Juan Pérez', $user->name);
        $this->assertEquals('juan@example.com', $user->email);
    }

    public function test_user_password_is_hashed(): void
    {
        $plainPassword = 'password123';
        $user = User::factory()->create([
            'password' => $plainPassword,
        ]);

        $this->assertNotEquals($plainPassword, $user->password);
    }

    public function test_user_password_is_hidden_in_array(): void
    {
        $user = User::factory()->create();

        $userArray = $user->toArray();
        $this->assertArrayNotHasKey('password', $userArray);
    }

    public function test_user_can_have_doctor_relationship(): void
    {
        $user = User::factory()->withDoctor()->create();

        $this->assertTrue($user->doctor()->exists());
        $this->assertNotNull($user->doctor->id);
    }

    public function test_user_can_have_patient_relationship(): void
    {
        $user = User::factory()->withPatient()->create();

        $this->assertTrue($user->patient()->exists());
        $this->assertNotNull($user->patient->id);
    }

    public function test_user_email_must_be_unique(): void
    {
        $user = User::factory()->create(['email' => 'duplicate@example.com']);

        $this->expectException(\Illuminate\Database\QueryException::class);
        User::factory()->create(['email' => 'duplicate@example.com']);
    }

    public function test_user_email_verified_at_is_cast_to_datetime(): void
    {
        $user = User::factory()->create(['email_verified_at' => now()]);

        $this->assertInstanceOf(\Carbon\Carbon::class, $user->email_verified_at);
    }

    public function test_user_can_be_updated(): void
    {
        $user = User::factory()->create(['name' => 'Original Name']);

        $user->update(['name' => 'Updated Name']);

        $this->assertEquals('Updated Name', $user->fresh()->name);
    }

    public function test_user_can_be_deleted(): void
    {
        $user = User::factory()->create();
        $userId = $user->id;

        $user->delete();

        $this->assertNull(User::find($userId));
    }
}
