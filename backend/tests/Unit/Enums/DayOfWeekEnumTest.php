<?php

namespace Tests\Unit\Enums;

use App\Enums\DayOfWeek;
use Tests\TestCase;

class DayOfWeekEnumTest extends TestCase
{
    /**
     * Test day of week enum cases exist
     */
    public function test_day_of_week_enum_cases_exist(): void
    {
        $this->assertNotNull(DayOfWeek::MONDAY);
        $this->assertNotNull(DayOfWeek::TUESDAY);
        $this->assertNotNull(DayOfWeek::WEDNESDAY);
        $this->assertNotNull(DayOfWeek::THURSDAY);
        $this->assertNotNull(DayOfWeek::FRIDAY);
        $this->assertNotNull(DayOfWeek::SATURDAY);
        $this->assertNotNull(DayOfWeek::SUNDAY);
    }

    /**
     * Test day of week enum values
     */
    public function test_day_of_week_enum_values(): void
    {
        $this->assertEquals('Monday', DayOfWeek::MONDAY->value);
        $this->assertEquals('Tuesday', DayOfWeek::TUESDAY->value);
        $this->assertEquals('Wednesday', DayOfWeek::WEDNESDAY->value);
        $this->assertEquals('Thursday', DayOfWeek::THURSDAY->value);
        $this->assertEquals('Friday', DayOfWeek::FRIDAY->value);
        $this->assertEquals('Saturday', DayOfWeek::SATURDAY->value);
        $this->assertEquals('Sunday', DayOfWeek::SUNDAY->value);
    }

    /**
     * Test day of week has 7 cases
     */
    public function test_day_of_week_has_seven_cases(): void
    {
        $cases = DayOfWeek::cases();
        $this->assertEquals(7, count($cases));
    }

    /**
     * Test day of week can be compared
     */
    public function test_day_of_week_can_be_compared(): void
    {
        $this->assertTrue(DayOfWeek::MONDAY === DayOfWeek::MONDAY);
        $this->assertFalse(DayOfWeek::MONDAY === DayOfWeek::TUESDAY);
    }
}
