<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Doctor;
use App\Models\Clinic;
use Illuminate\Support\Facades\DB;

class DoctorClinicSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $clinicaUady = Clinic::where('name', 'Clínica UADY')->first();
        $clinicaGeneral = Clinic::where('name', 'Clínica General')->first();

        if ($clinicaUady) {
            $doctor1 = Doctor::find(1);
            if ($doctor1) {
                $doctor1->clinics()->attach($clinicaUady->id, [
                    'office_number' => '15'
                ]);
            }

            $doctor2 = Doctor::find(2);
            if ($doctor2) {
                $doctor2->clinics()->attach($clinicaUady->id, [
                    'office_number' => '10'
                ]);
            }
        }

        if ($clinicaGeneral) {
            $doctor3 = Doctor::find(3);
            if ($doctor3) {
                $doctor3->clinics()->attach($clinicaGeneral->id, [
                    'office_number' => '5'
                ]);
            }
        }
    }
}
