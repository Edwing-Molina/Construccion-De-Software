<?php

namespace Tests\Unit\Enums;

use App\Enums\AppointmentStatus;
use Tests\TestCase;

class AppointmentStatusEnumTest extends TestCase
{
    /**
     * Test appointment status enum cases exist
     */
    public function test_appointment_status_enum_cases_exist(): void
    {
        $this->assertEquals('pendiente', AppointmentStatus::Pendiente->value);
        $this->assertEquals('completado', AppointmentStatus::Completado->value);
        $this->assertEquals('cancelada', AppointmentStatus::Cancelada->value);
    }

    /**
     * Test appointment status values method
     */
    public function test_appointment_status_values_method(): void
    {
        $values = AppointmentStatus::values();

        $this->assertIsArray($values);
        $this->assertContains('pendiente', $values);
        $this->assertContains('completado', $values);
        $this->assertContains('cancelada', $values);
    }

    /**
     * Test appointment status to array method
     */
    public function test_appointment_status_to_array_method(): void
    {
        $array = AppointmentStatus::toArray();

        $this->assertIsArray($array);
        $this->assertEquals(3, count($array));
    }

    /**
     * Test appointment status is valid method
     */
    public function test_appointment_status_is_valid_method(): void
    {
        $this->assertTrue(AppointmentStatus::isValid('pendiente'));
        $this->assertTrue(AppointmentStatus::isValid('completado'));
        $this->assertTrue(AppointmentStatus::isValid('cancelada'));
    }

    /**
     * Test appointment status is valid rejects invalid status
     */
    public function test_appointment_status_is_valid_rejects_invalid(): void
    {
        $this->assertFalse(AppointmentStatus::isValid('invalid'));
        $this->assertFalse(AppointmentStatus::isValid('pending'));
        $this->assertFalse(AppointmentStatus::isValid(''));
    }

    /**
     * Test appointment status is valid is case sensitive
     */
    public function test_appointment_status_is_valid_is_case_sensitive(): void
    {
        $this->assertFalse(AppointmentStatus::isValid('Pendiente'));
        $this->assertFalse(AppointmentStatus::isValid('PENDIENTE'));
        $this->assertTrue(AppointmentStatus::isValid('pendiente'));
    }

    /**
     * Test appointment status can be used in model
     */
    public function test_appointment_status_enum_can_be_cast_in_model(): void
    {
        $this->assertInstanceOf(AppointmentStatus::class, AppointmentStatus::Pendiente);
    }
}
