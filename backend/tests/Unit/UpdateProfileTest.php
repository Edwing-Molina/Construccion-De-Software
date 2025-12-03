<?php

namespace Tests\Unit;

use App\Models\Specialty;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UpdateProfileTest extends TestCase
{
    use RefreshDatabase;
    
    public function test_user_can_update_profile()
    {
        $user = User::factory()->withDoctor()->create();
        $specialty1 = Specialty::factory()->create();
        $specialty2 = Specialty::factory()->create();

        $response = $this->actingAs($user)
            ->putJson('/api/profile', [
                'name' => 'Nuevo Nombre',
                'specialty_ids' => [$specialty1->id, $specialty2->id],
            ]);

        $response->assertOk();
        $this->assertEquals('Nuevo Nombre', $user->fresh()->name);
    }

}


