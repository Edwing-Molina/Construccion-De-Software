<?php

namespace Tests\Unit\Services;

use App\Models\Doctor;
use App\Models\User;
use App\Models\Specialty;
use App\Models\Clinic;
use App\Services\DoctorService;
use Tests\TestCase;

class DoctorServiceTest extends TestCase
{
    private DoctorService $doctorService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->doctorService = new DoctorService();
    }

    /**
     * Test service can search doctors without filters
     */
    public function test_doctor_service_search_without_filters(): void
    {
        // Create test doctors
        $doctorUser = User::create([
            'name' => 'Dr. García',
            'email' => 'garcia@example.com',
            'password' => 'password123',
        ]);

        Doctor::create(['user_id' => $doctorUser->id]);

        $results = $this->doctorService->search();

        $this->assertNotNull($results);
        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    /**
     * Test service search returns paginated results
     */
    public function test_doctor_service_search_returns_pagination(): void
    {
        $results = $this->doctorService->search([], 5);

        $this->assertEquals(5, $results->perPage());
    }

    /**
     * Test service search by specialty
     */
    public function test_doctor_service_search_by_specialty(): void
    {
        // Create doctor with specialty
        $specialty = Specialty::create(['name' => 'Cardiology']);

        $doctorUser = User::create([
            'name' => 'Dr. Cardiologist',
            'email' => 'cardio@example.com',
            'password' => 'password123',
        ]);

        $doctor = Doctor::create(['user_id' => $doctorUser->id]);
        $doctor->specialties()->attach($specialty->id);

        $results = $this->doctorService->search(['specialty_id' => $specialty->id]);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    /**
     * Test service search by clinic
     */
    public function test_doctor_service_search_by_clinic(): void
    {
        $clinic = Clinic::create(['name' => 'Clinic Central']);

        $doctorUser = User::create([
            'name' => 'Dr. Clinic',
            'email' => 'clinic@example.com',
            'password' => 'password123',
        ]);

        $doctor = Doctor::create(['user_id' => $doctorUser->id]);
        $doctor->clinics()->attach($clinic->id, ['office_number' => '101']);

        $results = $this->doctorService->search(['clinic_id' => $clinic->id]);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    /**
     * Test service search by name
     */
    public function test_doctor_service_search_by_name(): void
    {
        $doctorUser = User::create([
            'name' => 'Dr. Unique Name',
            'email' => 'unique@example.com',
            'password' => 'password123',
        ]);

        Doctor::create(['user_id' => $doctorUser->id]);

        $results = $this->doctorService->search(['search' => 'Unique']);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    /**
     * Test service search by specialty using convenience method
     */
    public function test_doctor_service_search_by_specialty_convenience_method(): void
    {
        $specialty = Specialty::create(['name' => 'Neurology']);

        $doctorUser = User::create([
            'name' => 'Dr. Neurologist',
            'email' => 'neuro@example.com',
            'password' => 'password123',
        ]);

        $doctor = Doctor::create(['user_id' => $doctorUser->id]);
        $doctor->specialties()->attach($specialty->id);

        $results = $this->doctorService->searchBySpecialty($specialty->id);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    /**
     * Test service search with custom per page
     */
    public function test_doctor_service_search_with_custom_per_page(): void
    {
        $results = $this->doctorService->search([], 15);

        $this->assertEquals(15, $results->perPage());
    }

    /**
     * Test service search returns doctors with relationships
     */
    public function test_doctor_service_search_returns_loaded_relationships(): void
    {
        $doctorUser = User::create([
            'name' => 'Dr. With Relations',
            'email' => 'relations@example.com',
            'password' => 'password123',
        ]);

        $doctor = Doctor::create(['user_id' => $doctorUser->id]);

        $results = $this->doctorService->search();

        $this->assertNotNull($results->first());
        $this->assertNotNull($results->first()->user);
    }

    /**
     * Test service search with non existent specialty
     */
    public function test_doctor_service_search_with_non_existent_specialty(): void
    {
        $results = $this->doctorService->search(['specialty_id' => 99999]);

        $this->assertEquals(0, $results->total());
    }

    /**
     * Test service search combining multiple filters
     */
    public function test_doctor_service_search_with_multiple_filters(): void
    {
        $specialty = Specialty::create(['name' => 'Surgery']);
        $clinic = Clinic::create(['name' => 'Hospital Centro']);

        $doctorUser = User::create([
            'name' => 'Dr. Surgeon',
            'email' => 'surgeon@example.com',
            'password' => 'password123',
        ]);

        $doctor = Doctor::create(['user_id' => $doctorUser->id]);
        $doctor->specialties()->attach($specialty->id);
        $doctor->clinics()->attach($clinic->id, ['office_number' => '205']);

        $results = $this->doctorService->search([
            'specialty_id' => $specialty->id,
            'clinic_id' => $clinic->id,
        ]);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }
}
