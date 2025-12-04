<?php

namespace Tests\Unit\Models;

use App\Models\DoctorWorkPattern;
use App\Models\Doctor;
use App\Models\User;
use App\Models\Clinic;
use App\Enums\DayOfWeek;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DoctorWorkPatternModelTest extends TestCase
{
    use RefreshDatabase;

    private Doctor $doctor;
    private Clinic $clinic;

    protected function setUp(): void
    {
        parent::setUp();

        $user = User::factory()->withDoctor()->create();
        $this->doctor = $user->doctor;
        $this->clinic = Clinic::factory()->create();
    }

    /**
     * Test work pattern can be created
     */
    public function test_doctor_work_pattern_can_be_created(): void
    {
        $pattern = DoctorWorkPattern::create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::MONDAY->value,
            'start_time_pattern' => '09:00:00',
            'end_time_pattern' => '17:00:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
        ]);

        $this->assertNotNull($pattern->id);
        $this->assertTrue($pattern->is_active);
    }

    /**
     * Test work pattern belongs to doctor
     */
    public function test_doctor_work_pattern_belongs_to_doctor(): void
    {
        $pattern = DoctorWorkPattern::create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::TUESDAY->value,
            'start_time_pattern' => '08:00:00',
            'end_time_pattern' => '16:00:00',
            'slot_duration_minutes' => 45,
            'is_active' => true,
        ]);

        $this->assertTrue($pattern->doctor()->exists());
        $this->assertEquals($this->doctor->id, $pattern->doctor->id);
    }

    /**
     * Test work pattern belongs to clinic
     */
    public function test_doctor_work_pattern_belongs_to_clinic(): void
    {
        $pattern = DoctorWorkPattern::create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::WEDNESDAY->value,
            'start_time_pattern' => '09:00:00',
            'end_time_pattern' => '18:00:00',
            'slot_duration_minutes' => 60,
            'is_active' => true,
        ]);

        $this->assertTrue($pattern->clinic()->exists());
        $this->assertEquals($this->clinic->id, $pattern->clinic->id);
    }

    /**
     * Test work pattern day of week is cast to enum
     */
    public function test_doctor_work_pattern_day_of_week_cast_to_enum(): void
    {
        $pattern = DoctorWorkPattern::create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::THURSDAY->value,
            'start_time_pattern' => '09:00:00',
            'end_time_pattern' => '17:00:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
        ]);

        $this->assertInstanceOf(DayOfWeek::class, $pattern->fresh()->day_of_week);
    }

    /**
     * Test work pattern is active cast to boolean
     */
    public function test_doctor_work_pattern_is_active_cast_to_boolean(): void
    {
        $pattern = DoctorWorkPattern::create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::FRIDAY->value,
            'start_time_pattern' => '09:00:00',
            'end_time_pattern' => '17:00:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
        ]);

        $this->assertIsBool($pattern->fresh()->is_active);
    }

    /**
     * Test work pattern scope for doctor
     */
    public function test_doctor_work_pattern_scope_for_doctor(): void
    {
        DoctorWorkPattern::create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::SATURDAY->value,
            'start_time_pattern' => '10:00:00',
            'end_time_pattern' => '14:00:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
        ]);

        $results = DoctorWorkPattern::forDoctor($this->doctor->id)->get();

        $this->assertGreaterThanOrEqual(1, $results->count());
    }

    /**
     * Test work pattern throws exception for duplicate active pattern
     */
    public function test_doctor_work_pattern_throws_exception_for_duplicate(): void
    {
        DoctorWorkPattern::create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::SUNDAY->value,
            'start_time_pattern' => '09:00:00',
            'end_time_pattern' => '13:00:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
        ]);

        $this->expectException(\Exception::class);
        DoctorWorkPattern::createWorkPattern([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::SUNDAY->value,
            'start_time_pattern' => '09:00:00',
            'end_time_pattern' => '13:00:00',
            'is_active' => true,
        ]);
    }

    /**
     * Test work pattern can be created with different days
     */
    public function test_doctor_work_pattern_different_days_same_clinic(): void
    {
        $pattern1 = DoctorWorkPattern::create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::MONDAY->value,
            'start_time_pattern' => '09:00:00',
            'end_time_pattern' => '17:00:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
        ]);

        $pattern2 = DoctorWorkPattern::create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::TUESDAY->value,
            'start_time_pattern' => '09:00:00',
            'end_time_pattern' => '17:00:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
        ]);

        $this->assertNotEquals($pattern1->day_of_week, $pattern2->day_of_week);
    }

    /**
     * Test work pattern with effective date range
     */
    public function test_doctor_work_pattern_with_effective_date_range(): void
    {
        $pattern = DoctorWorkPattern::create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::MONDAY->value,
            'start_time_pattern' => '09:00:00',
            'end_time_pattern' => '17:00:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
            'start_date_effective' => Carbon::now(),
            'end_date_effective' => Carbon::now()->addMonths(3),
        ]);

        $this->assertNotNull($pattern->start_date_effective);
        $this->assertNotNull($pattern->end_date_effective);
    }
}
