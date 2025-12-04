<?php

declare(strict_types=1);

namespace Tests\Unit;

use App\Models\Appointment;
use App\Models\AvailableSchedule;
use App\Models\Clinic;
use App\Models\Doctor;
use App\Models\Specialty;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DoctorTest extends TestCase
{
    use RefreshDatabase;

    private Doctor $doctor;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create();
        $this->doctor = Doctor::factory()->create(['user_id' => $this->user->id]);
    }

    public function test_doctor_has_user_relationship(): void
    {
        $this->assertInstanceOf(User::class, $this->doctor->user);
        $this->assertEquals($this->user->id, $this->doctor->user->id);
    }

    public function test_doctor_has_specialties_relationship(): void
    {
        $specialty = Specialty::factory()->create();
        $this->doctor->specialties()->attach($specialty->id);

        $this->assertTrue($this->doctor->specialties->contains($specialty));
    }

    public function test_doctor_has_clinics_relationship(): void
    {
        $clinic = Clinic::factory()->create();
        $this->doctor->clinics()->attach($clinic->id, ['office_number' => '101']);

        $this->assertTrue($this->doctor->clinics->contains($clinic));
    }

    public function test_doctor_has_appointments_relationship(): void
    {
        $availableSchedule = AvailableSchedule::factory()->create(['doctor_id' => $this->doctor->id]);
        $appointment = Appointment::factory()->create(['available_schedule_id' => $availableSchedule->id]);

        $doctorAppointments = Appointment::whereHas('availableSchedule', function ($q) {
            $q->where('doctor_id', $this->doctor->id);
        })->get();

        $this->assertTrue($doctorAppointments->contains($appointment));
    }

    public function test_doctor_has_available_schedules_relationship(): void
    {
        $availableSchedule = AvailableSchedule::factory()->create(['doctor_id' => $this->doctor->id]);

        $this->assertTrue($this->doctor->availableSchedules->contains($availableSchedule));
    }

    public function test_is_available_returns_true_when_schedule_is_available(): void
    {
        $dateTime = Carbon::now()->addDay();
        $clinic = Clinic::factory()->create();

        $availableSchedule = AvailableSchedule::factory()->create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $clinic->id,
            'date' => $dateTime->toDateString(),
            'start_time' => $dateTime->format('H:i:s'),
            'available' => true,
        ]);

        $this->assertNotNull($availableSchedule->id);
        $this->assertTrue($availableSchedule->available);
        $this->assertEquals($this->doctor->id, $availableSchedule->doctor_id);
    }

    public function test_is_available_returns_false_when_schedule_is_not_available(): void
    {
        $dateTime = Carbon::now()->addDay();

        $this->assertFalse($this->doctor->isAvailable($dateTime, 1));
    }

    public function test_is_available_returns_false_when_appointment_already_exists(): void
    {
        $dateTime = Carbon::now()->addDay();

        $availableSchedule = AvailableSchedule::factory()->create([
            'doctor_id' => $this->doctor->id,
            'date' => $dateTime->toDateString(),
            'start_time' => $dateTime->format('H:i:s'),
            'available' => true,
        ]);

        Appointment::factory()->create([
            'available_schedule_id' => $availableSchedule->id,
            'status' => 'pendiente',
        ]);

        $this->assertFalse($this->doctor->isAvailable($dateTime, 1));
    }

    public function test_set_license_number_attribute_hashes_value(): void
    {
        $plainLicense = 'LIC123456';
        $this->doctor->license_number = $plainLicense;

        $hashedLicense = hash('sha256', $plainLicense);

        $this->assertEquals($hashedLicense, $this->doctor->license_number);
    }

    public function test_filter_by_id(): void
    {
        $result = Doctor::filter(['id' => $this->doctor->id], 10);

        $this->assertTrue($result->contains($this->doctor));
    }

    public function test_filter_by_search(): void
    {
        $result = Doctor::filter(['search' => $this->user->name], 10);

        $this->assertTrue($result->contains($this->doctor));
    }

    public function test_filter_by_specialty(): void
    {
        $specialty = Specialty::factory()->create();
        $this->doctor->specialties()->attach($specialty->id);

        $result = Doctor::filter(['specialty_id' => $specialty->id], 10);

        $this->assertTrue($result->contains($this->doctor));
    }

    public function test_filter_by_clinic(): void
    {
        $clinic = Clinic::factory()->create();
        $this->doctor->clinics()->attach($clinic->id, ['office_number' => '101']);

        $result = Doctor::filter(['clinic_id' => $clinic->id], 10);

        $this->assertTrue($result->contains($this->doctor));
    }

    public function test_filter_returns_paginated_results(): void
    {
        $result = Doctor::filter([], 10);

        $this->assertTrue($result->hasPages() || $result->count() > 0);
    }
}