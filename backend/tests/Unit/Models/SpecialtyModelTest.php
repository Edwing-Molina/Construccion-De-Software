<?php

namespace Tests\Unit\Models;

use App\Models\Specialty;
use App\Models\Doctor;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SpecialtyModelTest extends TestCase
{
    use RefreshDatabase;

    public function test_specialty_can_be_created_with_name(): void
    {
        $specialty = Specialty::factory()->create();

        $this->assertNotNull($specialty->id);
        $this->assertNotNull($specialty->name);
    }

    public function test_specialty_belongs_to_many_doctors(): void
    {
        $specialty = Specialty::factory()->create();
        $user = User::factory()->withDoctor()->create();
        $doctor = $user->doctor;

        $doctor->specialties()->attach($specialty->id);

        $this->assertTrue($specialty->doctors()->where('id', $doctor->id)->exists());
    }

    public function test_specialty_scope_filter_by_name(): void
    {
        Specialty::factory()->create(['name' => 'Cardiology']);
        Specialty::factory()->create(['name' => 'Neurology']);
        Specialty::factory()->create(['name' => 'Pediatrics']);

        $results = Specialty::filterByName('Cardio')->get();

        $this->assertEquals(1, $results->count());
        $this->assertEquals('Cardiology', $results->first()->name);
    }

    public function test_specialty_scope_filter_by_name_with_empty_string(): void
    {
        Specialty::factory()->create(['name' => 'Surgery']);
        Specialty::factory()->create(['name' => 'Oncology']);

        $results = Specialty::filterByName('')->get();

        $this->assertGreaterThanOrEqual(2, $results->count());
    }

    public function test_specialty_scope_ordered_by_name(): void
    {
        Specialty::factory()->create(['name' => 'Cardiology']);
        Specialty::factory()->create(['name' => 'Anesthesiology']);
        Specialty::factory()->create(['name' => 'Dermatology']);

        $results = Specialty::orderedByName()->get();

        $this->assertEquals('Anesthesiology', $results->first()->name);
        $this->assertEquals('Dermatology', $results->last()->name);
    }

    public function test_specialty_does_not_have_timestamps(): void
    {
        $specialty = Specialty::factory()->create();

        $this->assertNull($specialty->created_at);
        $this->assertNull($specialty->updated_at);
    }

    public function test_specialty_can_be_updated(): void
    {
        $specialty = Specialty::factory()->create(['name' => 'Original']);
        $specialty->update(['name' => 'Updated']);

        $this->assertEquals('Updated', $specialty->fresh()->name);
    }

    public function test_multiple_specialties_for_same_doctor(): void
    {
        $user = User::factory()->withDoctor()->create();
        $doctor = $user->doctor;

        $specialty1 = Specialty::factory()->create(['name' => 'Internal Medicine']);
        $specialty2 = Specialty::factory()->create(['name' => 'Infectious Disease']);

        $doctor->specialties()->attach([$specialty1->id, $specialty2->id]);

        $this->assertEquals(2, $doctor->specialties()->count());
    }
}
