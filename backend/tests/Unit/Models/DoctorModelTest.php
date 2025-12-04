<?php

namespace Tests\Unit\Models;

use App\Models\Doctor;
use App\Models\Patient;
use App\Models\User;
use App\Models\Specialty;
use App\Models\Clinic;
use App\Models\AvailableSchedule;
use App\Models\Appointment;
use Carbon\Carbon;
use Tests\TestCase;

class DoctorModelTest extends TestCase
{
    private User $doctorUser;
    private Doctor $doctor;

    protected function setUp(): void
    {
        parent::setUp();

        $this->doctorUser = User::factory()->create();
        $this->doctor = Doctor::factory()->for($this->doctorUser)->create();
    }

    /**
     * Test doctor belongs to user
     */
    public function test_doctor_belongs_to_user(): void
    {
        $this->assertTrue($this->doctor->user()->exists());
        $this->assertEquals($this->doctorUser->id, $this->doctor->user->id);
    }

    /**
     * Test doctor can have many specialties
     */
    public function test_doctor_can_have_many_specialties(): void
    {
        $specialty1 = Specialty::factory()->create();
        $specialty2 = Specialty::factory()->create();

        $this->doctor->specialties()->attach([$specialty1->id, $specialty2->id]);

        $this->assertEquals(2, $this->doctor->specialties()->count());
        $this->assertTrue($this->doctor->specialties()->where('id', $specialty1->id)->exists());
    }

    public function test_doctor_can_have_many_clinics(): void
    {
        $clinic1 = Clinic::factory()->create();
        $clinic2 = Clinic::factory()->create();

        $this->doctor->clinics()->attach([
            $clinic1->id => ['office_number' => '101'],
            $clinic2->id => ['office_number' => '202'],
        ]);

        $this->assertEquals(2, $this->doctor->clinics()->count());
    }

    public function test_doctor_can_have_many_appointments(): void
    {
        $patientUser = User::factory()->withPatient(['birth' => '1990-01-01'])->create();
        $patient = $patientUser->patient;

        $schedule = AvailableSchedule::factory()->for($this->doctor)->create([
            'date' => Carbon::now()->addDay(),
            'start_time' => '09:00:00',
            'end_time' => '09:30:00',
            'available' => true,
        ]);

        $appointment = Appointment::factory()->create([
            'patient_id' => $patient->id,
            'available_schedule_id' => $schedule->id,
        ]);

        $doctorAppointments = Appointment::whereHas('availableSchedule', function ($q) {
            $q->where('doctor_id', $this->doctor->id);
        })->count();

        $this->assertEquals(1, $doctorAppointments);
    }

    public function test_doctor_license_number_is_hashed(): void
    {
        $plainLicense = 'LIC123456';
        $this->doctor->update(['license_number' => $plainLicense]);

        $this->assertNotEquals($plainLicense, $this->doctor->fresh()->license_number);
    }

    public function test_doctor_is_available_with_valid_schedule(): void
    {
        $specialty = Specialty::factory()->create();
        $this->doctor->specialties()->attach($specialty->id);

        $requestedDateTime = Carbon::now()->addDay()->setTime(14, 0);
        $endDateTime = $requestedDateTime->copy()->addMinutes(30);

        $availableSchedule = AvailableSchedule::factory()->for($this->doctor)->create([
            'date' => $requestedDateTime->toDateString(),
            'start_time' => $requestedDateTime->format('H:i:s'),
            'end_time' => $endDateTime->format('H:i:s'),
            'available' => true,
        ]);

        $this->assertNotNull($availableSchedule->id);
        $this->assertTrue($availableSchedule->available);
        $this->assertEquals($this->doctor->id, $availableSchedule->doctor_id);
    }

    public function test_doctor_is_not_available_without_schedule(): void
    {
        $specialty = Specialty::factory()->create();
        $this->doctor->specialties()->attach($specialty->id);

        $requestedDateTime = Carbon::now()->addDay()->setTime(10, 0);

        $this->assertFalse($this->doctor->isAvailable($requestedDateTime, $specialty->id));
    }

    public function test_doctor_filter_by_specialty(): void
    {
        $specialty = Specialty::factory()->create();
        $this->doctor->specialties()->attach($specialty->id);

        $results = Doctor::filter(['specialty_id' => $specialty->id]);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    public function test_doctor_filter_by_search(): void
    {
        $results = Doctor::filter(['search' => $this->doctorUser->name]);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    public function test_doctor_uses_soft_deletes(): void
    {
        $this->doctor->delete();

        $this->assertSoftDeleted($this->doctor);
    }
}
