<?php

namespace Tests\Unit\Models;

use App\Models\Clinic;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ClinicModelTest extends TestCase
{
    use RefreshDatabase;

    public function test_clinic_can_be_created(): void
    {
        $clinic = Clinic::factory()->create();

        $this->assertNotNull($clinic->id);
        $this->assertNotNull($clinic->name);
    }

    public function test_clinic_can_be_updated(): void
    {
        $clinic = Clinic::factory()->create();
        $clinic->update(['name' => 'Updated Name']);

        $this->assertEquals('Updated Name', $clinic->fresh()->name);
    }

    public function test_clinic_can_be_deleted(): void
    {
        $clinic = Clinic::factory()->create();
        $clinicId = $clinic->id;

        $clinic->delete();

        $this->assertNull(Clinic::find($clinicId));
    }

    public function test_clinic_belongs_to_many_doctors(): void
    {
        $clinic = Clinic::factory()->create();

        $this->assertNotNull($clinic->doctors());
    }
}
