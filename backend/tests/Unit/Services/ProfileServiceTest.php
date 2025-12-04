<?php

namespace Tests\Unit\Services;

use App\Models\User;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\Specialty;
use App\Models\Clinic;
use App\Services\ProfileService;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProfileServiceTest extends TestCase
{
    use RefreshDatabase;

    private ProfileService $profileService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->profileService = new ProfileService();
    }

    public function test_profile_service_get_user_by_id(): void
    {
        $user = User::factory()->create(['name' => 'Profile User']);

        $retrieved = $this->profileService->getUserById($user->id);

        $this->assertEquals($user->id, $retrieved->id);
        $this->assertEquals('Profile User', $retrieved->name);
    }

    public function test_profile_service_get_user_throws_exception_for_non_existent(): void
    {
        $this->expectException(ModelNotFoundException::class);
        $this->profileService->getUserById(99999);
    }

    public function test_profile_service_update_basic_user_info(): void
    {
        $user = User::factory()->create(['name' => 'Original Name']);

        $updated = $this->profileService->updateUserProfile($user, [
            'name' => 'Updated Name',
            'phone' => '+52-555-1234',
        ]);

        $this->assertEquals('Updated Name', $updated->name);
        $this->assertEquals('+52-555-1234', $updated->phone);
    }

    public function test_profile_service_update_patient_info(): void
    {
        $user = User::factory()->withPatient([
            'birth' => '1990-01-01',
            'blood_type' => 'O+',
        ])->create();

        $updated = $this->profileService->updateUserProfile($user, [
            'patient' => [
                'blood_type' => 'AB+',
            ],
        ]);

        $this->assertEquals('AB+', $updated->patient->blood_type);
    }

    public function test_profile_service_update_doctor_specialties(): void
    {
        $user = User::factory()->withDoctor()->create();
        $specialty1 = Specialty::factory()->create();
        $specialty2 = Specialty::factory()->create();

        $updated = $this->profileService->updateUserProfile($user, [
            'specialty_ids' => [$specialty1->id, $specialty2->id],
        ]);

        $this->assertEquals(2, $updated->doctor->specialties()->count());
    }

    public function test_profile_service_throws_exception_for_invalid_specialty(): void
    {
        $user = User::factory()->withDoctor()->create();

        $this->expectException(\InvalidArgumentException::class);
        $this->profileService->updateUserProfile($user, [
            'specialty_ids' => [99999],
        ]);
    }

    public function test_profile_service_sync_doctor_clinics(): void
    {
        $user = User::factory()->withDoctor()->create();
        $clinic1 = Clinic::factory()->create();
        $clinic2 = Clinic::factory()->create();

        $updated = $this->profileService->updateUserProfile($user, [
            'clinics' => [
                ['clinic_id' => $clinic1->id, 'office_number' => '101'],
                ['clinic_id' => $clinic2->id, 'office_number' => '202'],
            ],
        ]);

        $this->assertEquals(2, $updated->doctor->clinics()->count());
    }

    public function test_profile_service_throws_exception_for_non_existent_clinic(): void
    {
        $user = User::factory()->withDoctor()->create();

        $this->expectException(ModelNotFoundException::class);
        $this->profileService->updateUserProfile($user, [
            'clinics' => [
                ['clinic_id' => 99999, 'office_number' => '101'],
            ],
        ]);
    }

    public function test_profile_service_transaction_rollback_on_error(): void
    {
        $user = User::factory()->withDoctor()->create();
        $originalName = $user->name;

        try {
            $this->profileService->updateUserProfile($user, [
                'name' => 'New Name',
                'specialty_ids' => [99999],
            ]);
        } catch (\InvalidArgumentException $e) {
        }

        $this->assertEquals($originalName, $user->fresh()->name);
    }

    public function test_profile_service_returns_user_with_relationships(): void
    {
        $user = User::factory()->withDoctor()->create();

        $updated = $this->profileService->updateUserProfile($user, [
            'name' => 'Updated',
        ]);

        $this->assertNotNull($updated->doctor);
    }

    public function test_profile_service_handles_empty_clinic_data(): void
    {
        $user = User::factory()->withDoctor()->create();

        $updated = $this->profileService->updateUserProfile($user, [
            'clinics' => [],
        ]);

        $this->assertEquals(0, $updated->doctor->clinics()->count());
    }
}
