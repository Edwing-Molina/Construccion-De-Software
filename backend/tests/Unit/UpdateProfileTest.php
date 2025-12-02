<?php

namespace Tests\Unit;

use App\Models\User;
use Tests\TestCase;

class UpdateProfileTest extends TestCase
{
    
    public function test_user_can_update_profile()
    {
        $user = User::factory()->withDoctor()->create();

        $response = $this->actingAs($user)
            ->putJson('/api/profile', [
                'name' => 'Nuevo Nombre',
                'specialty_ids' => [1, 2],
            ]);

        $response->assertOk();
        $this->assertEquals('Nuevo Nombre', $user->fresh()->name);
    }

}


