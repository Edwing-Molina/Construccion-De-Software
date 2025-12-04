<?php

namespace Tests\Unit\Services;

use App\Models\Doctor;
use App\Models\User;
use App\Models\Specialty;
use App\Models\Clinic;
use App\Services\DoctorService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DoctorServiceTest extends TestCase
{
    use RefreshDatabase;

    private DoctorService $doctorService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->doctorService = new DoctorService();
    }

    public function test_doctor_service_search_without_filters(): void
    {
        $user = User::factory()->withDoctor()->create();
        $results = $this->doctorService->search();

        $this->assertNotNull($results);
        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    public function test_doctor_service_search_returns_pagination(): void
    {
        $results = $this->doctorService->search([], 5);

        $this->assertEquals(5, $results->perPage());
    }

    public function test_doctor_service_search_by_specialty(): void
    {
        $specialty = Specialty::factory()->create();
        $user = User::factory()->withDoctor()->create();
        $user->doctor->specialties()->attach($specialty->id);

        $results = $this->doctorService->search(['specialty_id' => $specialty->id]);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    public function test_doctor_service_search_by_clinic(): void
    {
        $clinic = Clinic::factory()->create();
        $user = User::factory()->withDoctor()->create();
        $user->doctor->clinics()->attach($clinic->id, ['office_number' => '101']);

        $results = $this->doctorService->search(['clinic_id' => $clinic->id]);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    public function test_doctor_service_search_by_name(): void
    {
        $user = User::factory()->create(['name' => 'Dr. Unique Name']);
        Doctor::factory()->for($user)->create();

        $results = $this->doctorService->search(['search' => 'Unique']);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    public function test_doctor_service_search_by_specialty_convenience_method(): void
    {
        $specialty = Specialty::factory()->create();
        $user = User::factory()->withDoctor()->create();
        $user->doctor->specialties()->attach($specialty->id);

        $results = $this->doctorService->searchBySpecialty($specialty->id);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    public function test_doctor_service_search_with_custom_per_page(): void
    {
        $results = $this->doctorService->search([], 15);

        $this->assertEquals(15, $results->perPage());
    }

    public function test_doctor_service_search_returns_loaded_relationships(): void
    {
        $user = User::factory()->withDoctor()->create();
        $results = $this->doctorService->search();

        $this->assertNotNull($results->first());
        $this->assertNotNull($results->first()->user);
    }

    public function test_doctor_service_search_with_non_existent_specialty(): void
    {
        $results = $this->doctorService->search(['specialty_id' => 99999]);

        $this->assertEquals(0, $results->total());
    }

    public function test_doctor_service_search_with_multiple_filters(): void
    {
        $specialty = Specialty::factory()->create();
        $clinic = Clinic::factory()->create();
        $user = User::factory()->withDoctor()->create();
        $user->doctor->specialties()->attach($specialty->id);
        $user->doctor->clinics()->attach($clinic->id, ['office_number' => '205']);

        $results = $this->doctorService->search([
            'specialty_id' => $specialty->id,
            'clinic_id' => $clinic->id,
        ]);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }
}
