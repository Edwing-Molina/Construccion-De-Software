<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Specialty;
use Illuminate\Database\Eloquent\Factories\Factory;

final class SpecialtyFactory extends Factory
{
    protected $model = Specialty::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->unique()->randomElement([
                'Cardiología',
                'Dermatología',
                'Endocrinología',
                'Gastroenterología',
                'Ginecología',
                'Medicina General',
                'Medicina Interna',
                'Neurología',
                'Oftalmología',
                'Oncología',
                'Ortopedia',
                'Otorrinolaringología',
                'Pediatría',
                'Psiquiatría',
                'Radiología',
                'Traumatología',
                'Urología',
            ]),
        ];
    }
}
