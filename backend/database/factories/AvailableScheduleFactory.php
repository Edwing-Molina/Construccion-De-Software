<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\AvailableSchedule;
use App\Models\Doctor;
use App\Models\Clinic;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\Factory;

final class AvailableScheduleFactory extends Factory
{
    protected $model = AvailableSchedule::class;

    public function definition(): array
    {
        $date = $this->faker->dateTimeBetween('+1 day', '+30 days');
        
        return [
            'doctor_id' => Doctor::factory(),
            'clinic_id' => Clinic::factory(),
            'date' => $date,
            'start_time' => '09:00:00',
            'end_time' => '09:30:00',
            'available' => true,
        ];
    }
}
