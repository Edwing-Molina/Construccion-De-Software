<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Doctor;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

final class DoctorFactory extends Factory
{
    protected $model = Doctor::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'license_number' => $this->faker->regexify('[A-Z0-9]{10}'),
            'profile_picture_url' => $this->faker->imageUrl(),
            'is_active' => true,
            'description' => $this->faker->paragraph(),
        ];
    }
}
