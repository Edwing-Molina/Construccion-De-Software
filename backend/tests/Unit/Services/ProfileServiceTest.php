<?php

namespace Tests\Unit\Services;

use App\Models\User;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\Specialty;
use App\Models\Clinic;
use App\Services\ProfileService;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Tests\TestCase;

class ProfileServiceTest extends TestCase
{
    private ProfileService $profileService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->profileService = new ProfileService();
    }

    /**
     * Test service can get user by id
     */
    public function test_profile_service_get_user_by_id(): void
    {
        $user = User::create([
            'name' => 'Profile User',
            'email' => 'profile@example.com',
            'password' => 'password123',
        ]);

        $retrieved = $this->profileService->getUserById($user->id);

        $this->assertEquals($user->id, $retrieved->id);
        $this->assertEquals('Profile User', $retrieved->name);
    }

    /**
     * Test service throws exception for non existent user
     */
    public function test_profile_service_get_user_throws_exception_for_non_existent(): void
    {
        $this->expectException(ModelNotFoundException::class);
        $this->profileService->getUserById(99999);
    }

    /**
     * Test service can update basic user info
     */
    public function test_profile_service_update_basic_user_info(): void
    {
        $user = User::create([
            'name' => 'Original Name',
            'email' => 'update@example.com',
            'password' => 'password123',
        ]);

        $updated = $this->profileService->updateUserProfile($user, [
            'name' => 'Updated Name',
            'phone' => '+52-555-1234',
        ]);

        $this->assertEquals('Updated Name', $updated->name);
        $this->assertEquals('+52-555-1234', $updated->phone);
    }

    /**
     * Test service can update patient info
     */
    public function test_profile_service_update_patient_info(): void
    {
        $user = User::create([
            'name' => 'Patient User',
            'email' => 'patient.update@example.com',
            'password' => 'password123',
        ]);

        $patient = Patient::create([
            'user_id' => $user->id,
            'birth' => '1990-01-01',
            'blood_type' => 'O+',
        ]);

        $updated = $this->profileService->updateUserProfile($user, [
            'name' => 'Patient Updated',
            'patient' => [
                'blood_type' => 'AB+',
            ],
        ]);

        $this->assertEquals('AB+', $updated->patient->blood_type);
    }

    /**
     * Test service can update doctor specialties
     */
    public function test_profile_service_update_doctor_specialties(): void
    {
        $user = User::create([
            'name' => 'Doctor User',
            'email' => 'doctor.update@example.com',
            'password' => 'password123',
        ]);

        $doctor = Doctor::create(['user_id' => $user->id]);

        $specialty1 = Specialty::create(['name' => 'Cardiology']);
        $specialty2 = Specialty::create(['name' => 'Neurology']);

        $updated = $this->profileService->updateUserProfile($user, [
            'specialty_ids' => [$specialty1->id, $specialty2->id],
        ]);

        $this->assertEquals(2, $updated->doctor->specialties()->count());
    }

    /**
     * Test service throws exception for invalid specialty
     */
    public function test_profile_service_throws_exception_for_invalid_specialty(): void
    {
        $user = User::create([
            'name' => 'Doctor Invalid',
            'email' => 'doctor.invalid@example.com',
            'password' => 'password123',
        ]);

        Doctor::create(['user_id' => $user->id]);

        $this->expectException(\InvalidArgumentException::class);
        $this->profileService->updateUserProfile($user, [
            'specialty_ids' => [99999],
        ]);
    }

    /**
     * Test service can sync doctor clinics
     */
    public function test_profile_service_sync_doctor_clinics(): void
    {
        $user = User::create([
            'name' => 'Doctor Clinics',
            'email' => 'doctor.clinics@example.com',
            'password' => 'password123',
        ]);

        $doctor = Doctor::create(['user_id' => $user->id]);

        $clinic1 = Clinic::create(['name' => 'Clinic A']);
        $clinic2 = Clinic::create(['name' => 'Clinic B']);

        $updated = $this->profileService->updateUserProfile($user, [
            'clinics' => [
                ['clinic_id' => $clinic1->id, 'office_number' => '101'],
                ['clinic_id' => $clinic2->id, 'office_number' => '202'],
            ],
        ]);

        $this->assertEquals(2, $updated->doctor->clinics()->count());
    }

    /**
     * Test service throws exception for non existent clinic
     */
    public function test_profile_service_throws_exception_for_non_existent_clinic(): void
    {
        $user = User::create([
            'name' => 'Doctor No Clinic',
            'email' => 'doctor.noclnic@example.com',
            'password' => 'password123',
        ]);

        Doctor::create(['user_id' => $user->id]);

        $this->expectException(ModelNotFoundException::class);
        $this->profileService->updateUserProfile($user, [
            'clinics' => [
                ['clinic_id' => 99999, 'office_number' => '101'],
            ],
        ]);
    }

    /**
     * Test service update transaction rollback on error
     */
    public function test_profile_service_transaction_rollback_on_error(): void
    {
        $user = User::create([
            'name' => 'Transaction Test',
            'email' => 'transaction@example.com',
            'password' => 'password123',
        ]);

        Doctor::create(['user_id' => $user->id]);

        $originalName = $user->name;

        try {
            $this->profileService->updateUserProfile($user, [
                'name' => 'New Name',
                'specialty_ids' => [99999], // This will cause exception
            ]);
        } catch (\InvalidArgumentException $e) {
            // Expected exception
        }

        // Check if transaction was rolled back (name should not be updated)
        $this->assertEquals($originalName, $user->fresh()->name);
    }

    /**
     * Test service update returns user with loaded relationships
     */
    public function test_profile_service_returns_user_with_relationships(): void
    {
        $user = User::create([
            'name' => 'Relationships Test',
            'email' => 'relationships@example.com',
            'password' => 'password123',
        ]);

        Doctor::create(['user_id' => $user->id]);

        $updated = $this->profileService->updateUserProfile($user, [
            'name' => 'Updated',
        ]);

        $this->assertNotNull($updated->doctor);
    }

    /**
     * Test service handles empty clinic data
     */
    public function test_profile_service_handles_empty_clinic_data(): void
    {
        $user = User::create([
            'name' => 'Empty Clinics',
            'email' => 'empty.clinics@example.com',
            'password' => 'password123',
        ]);

        Doctor::create(['user_id' => $user->id]);

        $updated = $this->profileService->updateUserProfile($user, [
            'clinics' => [],
        ]);

        $this->assertEquals(0, $updated->doctor->clinics()->count());
    }
}
