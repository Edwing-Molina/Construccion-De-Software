<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Clinic;
use App\Models\Doctor;
use App\Models\DoctorWorkPattern;

use App\Enums\DayOfWeek;

class DoctorWorkPatternSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $doctor = Doctor::find(1); 
        $clinic = Clinic::find(1); 
        
        if (!$doctor || !$clinic) {
            $this->command->warn('No se encontraron doctores o clínicas. No se crearán patrones de trabajo.');
            return;
        }
        DoctorWorkPattern::firstOrCreate(
            [
                'doctor_id' => $doctor->id,
                'clinic_id' => $clinic->id,
                'day_of_week' => DayOfWeek::MONDAY, 
            ],
            [
                'start_time_pattern' => '09:00:00',
                'end_time_pattern' => '13:00:00',
                'slot_duration_minutes' => 30,
                'is_active' => true,
                'start_date_effective' => now()->subMonth()->toDateString(), 
                'end_date_effective' => null, 
            ]
        );

        DoctorWorkPattern::firstOrCreate(
            [
                'doctor_id' => $doctor->id,
                'clinic_id' => $clinic->id,
                'day_of_week' => DayOfWeek::TUESDAY, 
            ],
            [
                'start_time_pattern' => '10:00:00',
                'end_time_pattern' => '14:00:00',
                'slot_duration_minutes' => 30,
                'is_active' => true,
                'start_date_effective' => now()->subMonth()->toDateString(),
                'end_date_effective' => null,
            ]
        );

        // Puedes añadir más días o más patrones para el mismo doctor/clínica
        // o para otros doctores/clínicas si los creas en sus respectivos seeders.
        DoctorWorkPattern::firstOrCreate(
            [
                'doctor_id' => $doctor->id,
                'clinic_id' => $clinic->id,
                'day_of_week' => DayOfWeek::WEDNESDAY,
            ],
            [
                'start_time_pattern' => '09:00:00',
                'end_time_pattern' => '17:00:00',
                'slot_duration_minutes' => 60, 
                'is_active' => true,
                'start_date_effective' => now()->subMonth()->toDateString(),
                'end_date_effective' => now()->addMonths(6)->toDateString(),
            ]
        );

        $this->command->info('Patrones de trabajo creados exitosamente.');
    }
}

