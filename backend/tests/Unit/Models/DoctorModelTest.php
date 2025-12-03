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

        $this->doctorUser = User::create([
            'name' => 'Dr. Juan González',
            'email' => 'doctor.juan@example.com',
            'password' => 'password123',
        ]);

        $this->doctor = Doctor::create([
            'user_id' => $this->doctorUser->id,
        ]);
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
        $specialty1 = Specialty::create(['name' => 'Cardiology']);
        $specialty2 = Specialty::create(['name' => 'Neurology']);

        $this->doctor->specialties()->attach([$specialty1->id, $specialty2->id]);

        $this->assertEquals(2, $this->doctor->specialties()->count());
        $this->assertTrue($this->doctor->specialties()->where('id', $specialty1->id)->exists());
    }

    /**
     * Test doctor can have many clinics
     */
    public function test_doctor_can_have_many_clinics(): void
    {
        $clinic1 = Clinic::create(['name' => 'Clínica Central']);
        $clinic2 = Clinic::create(['name' => 'Clínica Norte']);

        $this->doctor->clinics()->attach([
            $clinic1->id => ['office_number' => '101'],
            $clinic2->id => ['office_number' => '202'],
        ]);

        $this->assertEquals(2, $this->doctor->clinics()->count());
    }

    /**
     * Test doctor can have many appointments
     */
    public function test_doctor_can_have_many_appointments(): void
    {
        $patient = Patient::create([
            'user_id' => User::create([
                'name' => 'Patient Name',
                'email' => 'patient@example.com',
                'password' => 'password123',
            ])->id,
            'birth' => '1990-01-01',
        ]);

        $schedule = AvailableSchedule::create([
            'doctor_id' => $this->doctor->id,
            'date' => Carbon::now()->addDay(),
            'start_time' => '09:00:00',
            'end_time' => '09:30:00',
            'available' => true,
        ]);

        Appointment::create([
            'patient_id' => $patient->id,
            'available_schedule_id' => $schedule->id,
            'status' => 'pendiente',
        ]);

        $this->assertEquals(1, $this->doctor->appointments()->count());
    }

    /**
     * Test doctor license number is hashed
     */
    public function test_doctor_license_number_is_hashed(): void
    {
        $plainLicense = 'LIC123456';
        $this->doctor->update(['license_number' => $plainLicense]);

        $this->assertNotEquals($plainLicense, $this->doctor->fresh()->license_number);
    }

    /**
     * Test doctor is available when schedule exists and no conflicts
     */
    public function test_doctor_is_available_with_valid_schedule(): void
    {
        $specialty = Specialty::create(['name' => 'General Practice']);
        $this->doctor->specialties()->attach($specialty->id);

        $requestedDateTime = Carbon::now()->addDay()->setTime(14, 0);
        $endDateTime = $requestedDateTime->copy()->addMinutes(30);

        AvailableSchedule::create([
            'doctor_id' => $this->doctor->id,
            'date' => $requestedDateTime->toDateString(),
            'start_time' => $requestedDateTime->format('H:i:s'),
            'end_time' => $endDateTime->format('H:i:s'),
            'available' => true,
        ]);

        $this->assertTrue($this->doctor->isAvailable($requestedDateTime, $specialty->id));
    }

    /**
     * Test doctor is not available when no schedule exists
     */
    public function test_doctor_is_not_available_without_schedule(): void
    {
        $specialty = Specialty::create(['name' => 'Surgery']);
        $this->doctor->specialties()->attach($specialty->id);

        $requestedDateTime = Carbon::now()->addDay()->setTime(10, 0);

        $this->assertFalse($this->doctor->isAvailable($requestedDateTime, $specialty->id));
    }

    /**
     * Test doctor filter by specialty
     */
    public function test_doctor_filter_by_specialty(): void
    {
        $specialty = Specialty::create(['name' => 'Pediatrics']);
        $this->doctor->specialties()->attach($specialty->id);

        $results = Doctor::filter(['specialty_id' => $specialty->id]);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    /**
     * Test doctor filter by search term
     */
    public function test_doctor_filter_by_search(): void
    {
        $results = Doctor::filter(['search' => 'Juan']);

        $this->assertGreaterThanOrEqual(1, $results->total());
    }

    /**
     * Test doctor uses soft deletes
     */
    public function test_doctor_uses_soft_deletes(): void
    {
        $this->doctor->delete();

        $this->assertSoftDeleted($this->doctor);
    }
}
