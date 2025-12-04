<?php

namespace Tests\Unit\Models;

use App\Models\Appointment;
use App\Models\AvailableSchedule;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\User;
use App\Enums\AppointmentStatus;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AppointmentModelTest extends TestCase
{
    use RefreshDatabase;

    private Patient $patient;
    private Doctor $doctor;
    private AvailableSchedule $schedule;

    protected function setUp(): void
    {
        parent::setUp();

        $patientUser = User::factory()->withPatient(['birth' => '1990-01-01'])->create();
        $this->patient = $patientUser->patient;

        $doctorUser = User::factory()->withDoctor()->create();
        $this->doctor = $doctorUser->doctor;

        $this->schedule = AvailableSchedule::factory()->for($this->doctor)->create([
            'date' => Carbon::now()->addDay(),
            'start_time' => '09:00:00',
            'end_time' => '09:30:00',
            'available' => true,
        ]);
    }

    /**
     * Test appointment can be created
     */
    public function test_appointment_can_be_created(): void
    {
        $appointment = Appointment::create([
            'patient_id' => $this->patient->id,
            'available_schedule_id' => $this->schedule->id,
            'status' => AppointmentStatus::Pendiente->value,
        ]);

        $this->assertNotNull($appointment->id);
        $this->assertEquals($this->patient->id, $appointment->patient_id);
    }

    /**
     * Test appointment belongs to patient
     */
    public function test_appointment_belongs_to_patient(): void
    {
        $appointment = Appointment::create([
            'patient_id' => $this->patient->id,
            'available_schedule_id' => $this->schedule->id,
            'status' => AppointmentStatus::Pendiente->value,
        ]);

        $this->assertTrue($appointment->patient()->exists());
        $this->assertEquals($this->patient->id, $appointment->patient->id);
    }

    /**
     * Test appointment belongs to available schedule
     */
    public function test_appointment_belongs_to_available_schedule(): void
    {
        $appointment = Appointment::create([
            'patient_id' => $this->patient->id,
            'available_schedule_id' => $this->schedule->id,
            'status' => AppointmentStatus::Pendiente->value,
        ]);

        $this->assertTrue($appointment->availableSchedule()->exists());
        $this->assertEquals($this->schedule->id, $appointment->availableSchedule->id);
    }

    /**
     * Test appointment has through relationship to doctor
     */
    public function test_appointment_has_one_through_doctor(): void
    {
        $appointment = Appointment::create([
            'patient_id' => $this->patient->id,
            'available_schedule_id' => $this->schedule->id,
            'status' => AppointmentStatus::Pendiente->value,
        ]);

        $this->assertTrue($appointment->doctor()->exists());
        $this->assertEquals($this->doctor->id, $appointment->doctor->id);
    }

    /**
     * Test appointment status is enum
     */
    public function test_appointment_status_is_cast_to_enum(): void
    {
        $appointment = Appointment::create([
            'patient_id' => $this->patient->id,
            'available_schedule_id' => $this->schedule->id,
            'status' => AppointmentStatus::Pendiente->value,
        ]);

        $this->assertInstanceOf(AppointmentStatus::class, $appointment->status);
    }

    /**
     * Test appointment filter by status
     */
    public function test_appointment_scope_filter_by_status(): void
    {
        Appointment::create([
            'patient_id' => $this->patient->id,
            'available_schedule_id' => $this->schedule->id,
            'status' => AppointmentStatus::Pendiente->value,
        ]);

        $results = Appointment::filterByStatus(AppointmentStatus::Pendiente->value)->get();

        $this->assertGreaterThanOrEqual(1, $results->count());
    }

    /**
     * Test appointment filter by doctor
     */
    public function test_appointment_scope_filter_by_doctor(): void
    {
        Appointment::create([
            'patient_id' => $this->patient->id,
            'available_schedule_id' => $this->schedule->id,
            'status' => AppointmentStatus::Pendiente->value,
        ]);

        $results = Appointment::filterByDoctor($this->doctor->id)->get();

        $this->assertGreaterThanOrEqual(1, $results->count());
    }

    /**
     * Test appointment filter by date range
     */
    public function test_appointment_scope_filter_by_date_range(): void
    {
        $appointment = Appointment::create([
            'patient_id' => $this->patient->id,
            'available_schedule_id' => $this->schedule->id,
            'status' => AppointmentStatus::Pendiente->value,
        ]);

        $fromDate = Carbon::now()->toDateString();
        $toDate = Carbon::now()->addDays(2)->toDateString();

        $results = Appointment::filterByDateRange($fromDate, $toDate)->get();

        $this->assertGreaterThanOrEqual(1, $results->count());
    }

    /**
     * Test appointment can be updated
     */
    public function test_appointment_can_be_updated(): void
    {
        $appointment = Appointment::create([
            'patient_id' => $this->patient->id,
            'available_schedule_id' => $this->schedule->id,
            'status' => AppointmentStatus::Pendiente->value,
        ]);

        $appointment->update(['status' => AppointmentStatus::Completado->value]);

        $this->assertEquals(AppointmentStatus::Completado->value, $appointment->fresh()->status->value);
    }
}
