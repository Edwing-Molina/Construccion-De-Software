<?php

namespace Database\Seeders;

use App\Models\Patient;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Enums\Genres;

class PatientSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {

        $userPatient = User::where('email', 'test@example.com')->find(1);
        if ($userPatient) {
            Patient::create([
                'user_id' => $userPatient->id,
                'birth' => today(),
                'gender' => Genres::Prefiero_no_decirlo->value,
                'blood_type' => 'O+',
                'emergency_contact_name' => 'John Doe',
                'emergency_contact_phone' => '1234567890',
                'nss_number' => '123-45-6789',
            ]);
        }

        $userPatient2 = User::where('email', 'test2@example.com')->find(2);
        if ($userPatient2) {
            Patient::create([
                'user_id' => $userPatient2->id,
                'birth' => today(),
                'gender' => Genres::Prefiero_no_decirlo->value,
                'blood_type' => 'A-',
                'emergency_contact_name' => 'Jane Doe',
                'emergency_contact_phone' => '0987654321',
                'nss_number' => '987-65-4321',
            ]);
        }
    }
}
