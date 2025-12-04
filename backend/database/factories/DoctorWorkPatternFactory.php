<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\DoctorWorkPattern;
use App\Models\Doctor;
use App\Models\Clinic;
use App\Enums\DayOfWeek;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\Factory;

final class DoctorWorkPatternFactory extends Factory
{
    protected $model = DoctorWorkPattern::class;

    public function definition(): array
    {
        return [
            'doctor_id' => Doctor::factory(),
            'clinic_id' => Clinic::factory(),
            'day_of_week' => $this->faker->randomElement(DayOfWeek::cases())->value,
            'start_time_pattern' => '09:00',
            'end_time_pattern' => '17:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
            'start_date_effective' => Carbon::now()->toDateString(),
            'end_date_effective' => Carbon::now()->addMonths(6)->toDateString(),
        ];
    }
}
