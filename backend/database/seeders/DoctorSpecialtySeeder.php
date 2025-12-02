<?php

namespace Database\Seeders;

use App\Models\Doctor;
use App\Models\Specialty;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DoctorSpecialtySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $doctor = Doctor::find(1);
        $doctor2 = Doctor::find(2);
        $specialty = Specialty::where('name', 'Dermatologia')->first();
        $specialty2 = Specialty::where('name', 'Pediatria')->first();

        if ($doctor && $specialty) {
            $doctor->specialtys()->attach($specialty->id);
            $this->command->info("Asignada especialidad '{$specialty->name}' al doctor '{$doctor->user->name}'.");
        } else {
            $this->command->warn("No se pudo encontrar el doctor o la especialidad para asignación.");
        }

        if ($doctor2 && $specialty2) {
            $doctor2->specialtys()->attach($specialty2->id);
            $this->command->info("Asignada especialidad '{$specialty2->name}' al doctor '{$doctor2->user->name}'.");
        } else {
            $this->command->warn("No se pudo encontrar el doctor o la especialidad para asignación.");
        }
    }
}
