<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;

class GetUserToken extends Command
{
    protected $signature = 'get:user-token {user_id}';
    protected $description = 'Get authentication token for a user';

    public function handle()
    {
        $userId = $this->argument('user_id');
        $user = User::find($userId);
        
        if (!$user) {
            $this->error('Usuario no encontrado');
            return;
        }

        // Crear un token de acceso personal
        $token = $user->createToken('test-token')->plainTextToken;
        
        $this->info('User: ' . $user->name . ' (ID: ' . $user->id . ')');
        $this->info('Token: ' . $token);
        
        return $token;
    }
}
