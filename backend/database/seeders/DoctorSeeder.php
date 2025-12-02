<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Doctor;

class DoctorSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $doctorUser1 = User::where('email', 'testDoctor@example.com')->find(3);
        if ($doctorUser1) {
            Doctor::create([
                'user_id' => $doctorUser1->id,
                'license_number' => 'AAAAAAAAA888999',
                'profile_picture_url' => 'https://profile_picture.com',
                'description' => 'Soy un doctor'
            ]);
        }

        $doctorUser2 = User::where('email', 'testDoctor2@example.com')->find(4);
        if ($doctorUser2) {
            Doctor::create([
                'user_id' => $doctorUser2->id,
                'license_number' => 'AAAAAAAAJAJAJ112',
                'profile_picture_url' => 'https://profile_picture2.com',
                'description' => 'Soy un doctor'
            ]);
        }
    }
}
