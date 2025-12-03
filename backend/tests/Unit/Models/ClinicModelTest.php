<?php

namespace Tests\Unit\Models;

use App\Models\Clinic;
use Tests\TestCase;

class ClinicModelTest extends TestCase
{
    /**
     * Test clinic can be created
     */
    public function test_clinic_can_be_created(): void
    {
        $clinic = Clinic::create([
            'name' => 'Hospital Central',
        ]);

        $this->assertNotNull($clinic->id);
        $this->assertEquals('Hospital Central', $clinic->name);
    }

    /**
     * Test clinic can be updated
     */
    public function test_clinic_can_be_updated(): void
    {
        $clinic = Clinic::create(['name' => 'Original Name']);
        $clinic->update(['name' => 'Updated Name']);

        $this->assertEquals('Updated Name', $clinic->fresh()->name);
    }

    /**
     * Test clinic can be deleted
     */
    public function test_clinic_can_be_deleted(): void
    {
        $clinic = Clinic::create(['name' => 'Clinic To Delete']);
        $clinicId = $clinic->id;

        $clinic->delete();

        $this->assertNull(Clinic::find($clinicId));
    }

    /**
     * Test clinic belongs to many doctors
     */
    public function test_clinic_belongs_to_many_doctors(): void
    {
        $clinic = Clinic::create(['name' => 'Multi Doctor Clinic']);

        // Test that relationship exists
        $this->assertNotNull($clinic->doctors());
    }
}
