<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;

class CheckUsers extends Command
{
    protected $signature = 'check:users';
    protected $description = 'Check existing users and their roles';

    public function handle()
    {
        $users = User::with(['doctor', 'patient'])->get();
        
        $this->info('Users in database:');
        foreach ($users as $user) {
            $this->line("ID: {$user->id}, Name: {$user->name}, Email: {$user->email}");
            
            if ($user->doctor) {
                $this->line("  - Has Doctor profile (ID: {$user->doctor->id})");
                $clinics = $user->doctor->clinics;
                if ($clinics->count() > 0) {
                    foreach ($clinics as $clinic) {
                        $this->line("    - Clinic: {$clinic->name} (Office: " . ($clinic->pivot->office_number ?? 'N/A') . ")");
                    }
                } else {
                    $this->line("    - No clinics assigned");
                }
            }
            
            if ($user->patient) {
                $this->line("  - Has Patient profile (ID: {$user->patient->id})");
            }
            
            $this->line('');
        }
    }
}
