<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Appointment;
use App\Models\Patient;
use App\Models\AvailableSchedule;
use App\Enums\AppointmentStatus;
use Illuminate\Database\Eloquent\Factories\Factory;

final class AppointmentFactory extends Factory
{
    protected $model = Appointment::class;

    public function definition(): array
    {
        return [
            'patient_id' => Patient::factory(),
            'available_schedule_id' => AvailableSchedule::factory(),
            'status' => AppointmentStatus::Pendiente->value,
        ];
    }
}
