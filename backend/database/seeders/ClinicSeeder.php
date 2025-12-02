<?php

namespace Database\Seeders;

use App\Models\Clinic;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class ClinicSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Crear clínica principal UADY
        Clinic::create([
            'name' => 'Clínica UADY',
            'address' => 'Carretera Mérida-Xmatkuil Km. 15.5, 97000 Mérida, Yuc.'
        ]);

        // Crear clínica adicional para testing
        Clinic::create([
            'name' => 'Clínica General',
            'address' => 'Dirección falsa 123'
        ]);
    }
}
