<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Clinic;
use Illuminate\Database\Eloquent\Factories\Factory;

final class ClinicFactory extends Factory
{
    protected $model = Clinic::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->company() . ' Clinic',
            'address' => $this->faker->address(),
        ];
    }
}
