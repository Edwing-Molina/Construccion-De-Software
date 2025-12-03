<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class RolesAndPermissionsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        
        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        
        $patientRole = Role::firstOrCreate(['name' => 'patient']);
        $doctorRole = Role::firstOrCreate(['name' => 'doctor']);

        
        $permissions = [
            'view own profile',
            'edit own profile',
            'view doctors list',
            'view specialtys list',
            'view own appointments',
            'create appointment',
            'cancel own appointment',
            'complete appointment',
            'create a work pattern',
            'create available schedules',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        

        
        $doctorRole->syncPermissions([
            'view own profile',
            'edit own profile',
            'complete appointment',
            'create a work pattern',
            'create available schedules',
        ]);

        
        $patientRole->syncPermissions([
            'view own profile',
            'edit own profile',
            'view doctors list',
            'view specialtys list',
            'view own appointments',
            'create appointment',
            'cancel own appointment',
        ]);
    }
}