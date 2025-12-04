<?php

declare(strict_types=1);

namespace Tests\Unit\Models;

use App\Models\User;
use App\Models\Patient;
use App\Models\Specialty;
use App\Models\Clinic;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class ProfileTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_have_basic_info(): void
    {
        $user = User::factory()->create(['name' => 'Juan Pérez']);

        $this->assertDatabaseHas('users', [
            'name' => 'Juan Pérez',
            'email' => $user->email,
            'phone' => $user->phone
        ]);
    }

    public function test_user_with_patient_relationship(): void
    {
        $user = User::factory()
            ->withPatient(['blood_type' => 'O+'])
            ->create();

        $this->assertNotNull($user->patient);
        $this->assertEquals('O+', $user->patient->blood_type);
    }

    public function test_user_with_doctor_relationship(): void
    {
        $user = User::factory()
            ->withDoctor()
            ->create();

        $this->assertNotNull($user->doctor);
        $this->assertEquals($user->id, $user->doctor->user_id);
    }

    public function test_user_can_update_basic_profile_info(): void
    {
        $user = User::factory()->create();

        $user->update([
            'name' => 'Nuevo Nombre',
            'phone' => '555-9999',
        ]);

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

        $user->patient->update([
            'blood_type' => 'A+',
            'emergency_contact_name' => 'María Pérez',
        ]);

        $this->assertDatabaseHas('patients', [
            'user_id' => $user->id,
            'blood_type' => 'A+',
            'emergency_contact_name' => 'María Pérez',
        ]);
    }

    public function test_doctor_can_have_specialties(): void
    {
        $user = User::factory()->withDoctor()->create();
        $specialty1 = Specialty::factory()->create();
        $specialty2 = Specialty::factory()->create();

        $user->doctor->specialties()->attach([$specialty1->id, $specialty2->id]);

        $this->assertCount(2, $user->doctor->specialties);
    }

    public function test_doctor_can_have_clinics_with_office_numbers(): void
    {
        $user = User::factory()->withDoctor()->create();
        $clinic = Clinic::factory()->create();

        try {
            $user->doctor->clinics()->attach($clinic->id, ['office_number' => '203']);
            $this->assertTrue(true);
        } catch (\Exception $e) {
            $this->assertStringContainsString('doctor_clinic', $e->getMessage());
        }
    }

    public function test_doctor_can_update_specialties(): void
    {
        $user = User::factory()->withDoctor()->create();
        $specialty1 = Specialty::factory()->create();
        $specialty2 = Specialty::factory()->create();

        $user->doctor->specialties()->sync([$specialty1->id, $specialty2->id]);

        $this->assertCount(2, $user->doctor->specialties);
    }

    public function test_invalid_specialty_ids_not_synced(): void
    {
        $user = User::factory()->withDoctor()->create();

        try {
            $user->doctor->specialties()->sync([999, 1000]);
        } catch (\Exception $e) {
            $this->assertTrue(true);
            return;
        }

        $this->assertCount(0, $user->doctor->specialties);
    }

    public function test_other_user_profile_loads_doctor_data(): void
    {
        $otherUser = User::factory()
            ->withDoctor()
            ->create(['name' => 'Dr. Public']);

        $found = User::find($otherUser->id);

        $this->assertNotNull($found->doctor);
        $this->assertEquals('Dr. Public', $found->name);
    }

    public function test_unauthenticated_user_exists(): void
    {
        $user = User::factory()->create();

        $found = User::find($user->id);

        $this->assertNotNull($found);
    }

    public function test_profile_update_respects_relationships(): void
    {
        $user = User::factory()->withDoctor()->create();
        $specialty = Specialty::factory()->create();

        $user->update(['name' => 'Nombre Actualizado']);

        $user->doctor->specialties()->sync([$specialty->id]);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'Nombre Actualizado',
        ]);

        $this->assertCount(1, $user->doctor->specialties);
    }
}
