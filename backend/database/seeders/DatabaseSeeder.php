<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;

use App\Models\AvailableSchedule;
use App\Models\Doctor;
use App\Models\DoctorWorkPattern;
use App\Models\Specialty;
use Illuminate\Database\Seeder;


class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            RolesAndPermissionsSeeder::class,

            UserSeeder::class,

            DoctorSeeder::class,

            PatientSeeder::class,

            SpecialtySeeder::class,

            DoctorSpecialtySeeder::class,

            ClinicSeeder::class,

            DoctorClinicSeeder::class,

            DoctorWorkPatternSeeder::class,

            AvailableScheduleSeeder::class,

            AppointmentSeeder::class,
        ]);
    }

}
