<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Doctor;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $userPatient = User::factory()->create([
            'name' => 'Edgar cambranes',
            'email' => 'test@example.com',
            'phone' => '9999999999',
            'password' => Hash::make('password'),
        ]);
        $userPatient->assignRole('patient');

        $secondUserPatient = User::create([
            'name' => 'Test User 2',
            'email' => 'test2@example.com',
            'phone' => '9999999997',
            'password' => Hash::make('password'),
        ]);
        $secondUserPatient->assignRole('patient');
        
        $userDoctor = User::factory()->create([
            'name' => 'Edwing molina',
            'email' => 'testDoctor@example.com',
            'phone' => '9999999998',
            'password' => Hash::make('password'),
        ]);
        $userDoctor->assignRole('doctor');

        $secondUserDoctor = User::create([
            'name' => 'Test User Doctor 2',
            'email' => 'testDoctor2@example.com',
            'phone' => '9999999996',
            'password' => Hash::make('password'),
        ]);
        $secondUserDoctor->assignRole('doctor');
        
    }
}
