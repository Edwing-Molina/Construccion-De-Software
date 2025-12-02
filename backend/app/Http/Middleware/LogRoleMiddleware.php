<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Spatie\Permission\Middleware\RoleMiddleware;

class LogRoleMiddleware extends RoleMiddleware
{
    public function handle($request, Closure $next, $role, $guard = null)
    {
        $user = $request->user($guard);

        if ($user) {
            Log::info("Roles del usuario autenticado:", ['user_id' => $user->id, 'roles' => $user->roles]);
        }

        return parent::handle($request, $next, $role, $guard);
    }
}
