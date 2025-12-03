<?php

namespace Tests\Unit\Models;

use App\Models\AvailableSchedule;
use App\Models\Doctor;
use App\Models\User;
use Carbon\Carbon;
use Tests\TestCase;

class AvailableScheduleModelTest extends TestCase
{
    private Doctor $doctor;
    private AvailableSchedule $schedule;

    protected function setUp(): void
    {
        parent::setUp();

        $user = User::create([
            'name' => 'Dr. Schedule Test',
            'email' => 'schedule@example.com',
            'password' => 'password123',
        ]);

        $this->doctor = Doctor::create(['user_id' => $user->id]);

        $this->schedule = AvailableSchedule::create([
            'doctor_id' => $this->doctor->id,
            'date' => Carbon::now()->addDay(),
            'start_time' => '09:00:00',
            'end_time' => '09:30:00',
            'available' => true,
        ]);
    }

    /**
     * Test schedule can be created
     */
    public function test_available_schedule_can_be_created(): void
    {
        $this->assertNotNull($this->schedule->id);
        $this->assertEquals($this->doctor->id, $this->schedule->doctor_id);
        $this->assertTrue($this->schedule->available);
    }

    /**
     * Test schedule belongs to doctor
     */
    public function test_available_schedule_belongs_to_doctor(): void
    {
        $this->assertTrue($this->schedule->doctor()->exists());
        $this->assertEquals($this->doctor->id, $this->schedule->doctor->id);
    }

    /**
     * Test schedule date is cast to date
     */
    public function test_available_schedule_date_is_cast_to_date(): void
    {
        $this->assertInstanceOf(Carbon::class, $this->schedule->date);
    }

    /**
     * Test schedule available is cast to boolean
     */
    public function test_available_schedule_available_is_cast_to_boolean(): void
    {
        $this->assertIsBool($this->schedule->available);
    }

    /**
     * Test mark schedule as available
     */
    public function test_mark_available_schedule_as_available(): void
    {
        $this->schedule->update(['available' => false]);
        $this->assertFalse($this->schedule->fresh()->available);

        $result = $this->schedule->markAsAvailable();

        $this->assertTrue($result);
        $this->assertTrue($this->schedule->fresh()->available);
    }

    /**
     * Test mark schedule as unavailable
     */
    public function test_mark_available_schedule_as_unavailable(): void
    {
        $result = $this->schedule->markAsUnavailable();

        $this->assertTrue($result);
        $this->assertFalse($this->schedule->fresh()->available);
    }

    /**
     * Test check if schedule is available
     */
    public function test_check_if_schedule_is_available(): void
    {
        $this->assertTrue($this->schedule->isAvailable());

        $this->schedule->markAsUnavailable();

        $this->assertFalse($this->schedule->fresh()->isAvailable());
    }

    /**
     * Test check if schedule is in future
     */
    public function test_check_if_schedule_is_in_future(): void
    {
        $futureSchedule = AvailableSchedule::create([
            'doctor_id' => $this->doctor->id,
            'date' => Carbon::now()->addDays(5),
            'start_time' => '14:00:00',
            'end_time' => '14:30:00',
            'available' => true,
        ]);

        $this->assertTrue($futureSchedule->isInFuture());
    }

    /**
     * Test check if past schedule is not in future
     */
    public function test_past_schedule_is_not_in_future(): void
    {
        $pastSchedule = AvailableSchedule::create([
            'doctor_id' => $this->doctor->id,
            'date' => Carbon::now()->subDays(1),
            'start_time' => '10:00:00',
            'end_time' => '10:30:00',
            'available' => true,
        ]);

        $this->assertFalse($pastSchedule->isInFuture());
    }

    /**
     * Test schedule has many appointments
     */
    public function test_available_schedule_has_many_appointments(): void
    {
        $this->assertEquals(0, $this->schedule->appointments()->count());
    }

    /**
     * Test schedule can be updated
     */
    public function test_available_schedule_can_be_updated(): void
    {
        $this->schedule->update([
            'start_time' => '10:00:00',
            'end_time' => '10:30:00',
        ]);

        $updated = $this->schedule->fresh();
        $this->assertEquals('10:00:00', $updated->start_time);
    }
}
