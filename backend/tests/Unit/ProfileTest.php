<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\Specialty;
use App\Models\Clinic;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class ProfileTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_view_own_profile(): void
    {
        $user = User::factory()->create(['name' => 'Juan Pérez']);

        $response = $this->actingAs($user)
            ->getJson('/api/profile');

        $response->assertOk()
            ->assertJsonFragment(['name' => 'Juan Pérez'])
            ->assertJsonStructure([
                'message',
                'data' => ['id', 'name', 'email', 'phone']
            ]);
    }

    public function test_profile_includes_patient_data_when_user_is_patient(): void
    {
        $user = User::factory()
            ->withPatient(['blood_type' => 'O+'])
            ->create();

        $response = $this->actingAs($user)
            ->getJson('/api/profile');

        $response->assertOk()
            ->assertJsonStructure([
                'data' => [
                    'patient' => ['id', 'birth', 'blood_type']
                ]
            ])
            ->assertJsonFragment(['blood_type' => 'O+']);
    }

    public function test_profile_includes_doctor_data_when_user_is_doctor(): void
    {
        $user = User::factory()
            ->withDoctor(['consultation_fee' => 500])
            ->create();

        $response = $this->actingAs($user)
            ->getJson('/api/profile');

        $response->assertOk()
            ->assertJsonStructure([
                'data' => [
                    'doctor' => ['id', 'consultation_fee']
                ]
            ])
            ->assertJsonFragment(['consultation_fee' => 500]);
    }

    public function test_user_can_update_basic_profile_info(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)
            ->putJson('/api/profile', [
                'name' => 'Nuevo Nombre',
                'phone' => '555-9999',
            ]);

        $response->assertOk()
            ->assertJsonFragment(['name' => 'Nuevo Nombre']);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'Nuevo Nombre',
            'phone' => '555-9999',
        ]);
    }

    public function test_patient_can_update_patient_specific_data(): void
    {
        $user = User::factory()
            ->withPatient(['blood_type' => 'O+'])
            ->create();

        $response = $this->actingAs($user)
            ->putJson('/api/profile', [
                'patient' => [
                    'blood_type' => 'A+',
                    'emergency_contact_name' => 'María Pérez',
                ],
            ]);

        $response->assertOk();

        $this->assertDatabaseHas('patients', [
            'user_id' => $user->id,
            'blood_type' => 'A+',
            'emergency_contact_name' => 'María Pérez',
        ]);
    }

    public function test_doctor_can_update_specialties(): void
    {
        $user = User::factory()->withDoctor()->create();
        $specialty1 = Specialty::factory()->create();
        $specialty2 = Specialty::factory()->create();

        $response = $this->actingAs($user)
            ->putJson('/api/profile', [
                'specialty_ids' => [$specialty1->id, $specialty2->id],
            ]);

        $response->assertOk();

        $this->assertDatabaseHas('doctor_specialty', [
            'doctor_id' => $user->doctor->id,
            'specialty_id' => $specialty1->id,
        ]);

        $this->assertDatabaseHas('doctor_specialty', [
            'doctor_id' => $user->doctor->id,
            'specialty_id' => $specialty2->id,
        ]);
    }

    public function test_doctor_can_update_clinics_with_office_numbers(): void
    {
        $user = User::factory()->withDoctor()->create();
        $clinic = Clinic::factory()->create();

        $response = $this->actingAs($user)
            ->putJson('/api/profile', [
                'clinics' => [
                    [
                        'clinic_id' => $clinic->id,
                        'office_number' => '203',
                    ],
                ],
            ]);

        $response->assertOk();

        $this->assertDatabaseHas('doctor_clinic', [
            'doctor_id' => $user->doctor->id,
            'clinic_id' => $clinic->id,
            'office_number' => '203',
        ]);
    }

    public function test_update_fails_with_invalid_specialty_ids(): void
    {
        $user = User::factory()->withDoctor()->create();

        $response = $this->actingAs($user)
            ->putJson('/api/profile', [
                'specialty_ids' => [999, 1000], // IDs que no existen
            ]);

        $response->assertUnprocessable();
    }

    public function test_can_view_other_user_public_profile(): void
    {
        $currentUser = User::factory()->create();
        $otherUser = User::factory()
            ->withDoctor(['license_number' => 'SECRET123'])
            ->create(['name' => 'Dr. Public']);

        $response = $this->actingAs($currentUser)
            ->getJson("/api/users/{$otherUser->id}/profile");

        $response->assertOk()
            ->assertJsonFragment(['name' => 'Dr. Public'])
            ->assertJsonMissing(['license_number' => 'SECRET123']); // Dato sensible oculto
    }

    public function test_unauthenticated_user_cannot_access_profile(): void
    {
        $response = $this->getJson('/api/profile');

        $response->assertUnauthorized();
    }

    public function test_profile_update_is_atomic(): void
    {
        $user = User::factory()->withDoctor()->create();

        // Intentar actualizar con specialty_id inválido
        $this->actingAs($user)
            ->putJson('/api/profile', [
                'name' => 'Nombre Actualizado',
                'specialty_ids' => [999], // ID inválido
            ]);

        // El nombre NO debe haberse actualizado (rollback)
        $this->assertDatabaseMissing('users', [
            'id' => $user->id,
            'name' => 'Nombre Actualizado',
        ]);
    }
}
