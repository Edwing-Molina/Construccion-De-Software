<?php

namespace Tests\Unit\Models;

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

        $user->update([
            'name' => 'Nuevo Nombre',
        ]);

        $user->doctor->specialties()->sync([$specialty1->id, $specialty2->id]);

        $this->assertEquals('Nuevo Nombre', $user->fresh()->name);
        $this->assertCount(2, $user->doctor->specialties);
    }
}



