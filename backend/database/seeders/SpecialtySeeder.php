<?php

namespace Database\Seeders;

use App\Models\Specialty;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class SpecialtySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $specialty = Specialty::create([
            'name' => 'Dermatologia',
        ]);

        $specialty2 = Specialty::create([
            'name' => 'Pediatria',
        ]);
    }
}
