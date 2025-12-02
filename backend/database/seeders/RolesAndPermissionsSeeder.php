<?php

namespace Database\Seeders;

use GuzzleHttp\Promise\Create;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RolesAndPermissionsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        $patientRole = Role::firstOrCreate(['name' => 'patient']);
        $doctorRole = Role::firstOrCreate(['name' => 'doctor']);

        Permission::create(['name' => 'view own profile']);
        Permission::create(['name' => 'edit own profile']);

        Permission::create(['name' => 'view doctors list']);
        Permission::create(['name' => 'view specialtys list']);

        Permission::create(['name' => 'view own appointments']);
        Permission::create(['name' => 'create appointment']);
        Permission::create(['name' => 'cancel own appointment']);
        Permission::create(['name' => 'complete appointment']);

        Permission::create(['name' => 'create a work pattern']);
        Permission::create(['name' => 'create available schedules']);
        
        // ...

        $patientRole = Role::findByName('patient');
        $patientRole->givePermissionTo([]);

        $doctorRole = Role::findByName('doctor');
        $doctorRole->givePermissionTo(['']); 
    }
}
