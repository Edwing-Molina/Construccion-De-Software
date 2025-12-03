<?php

namespace Tests\Unit\Models;

use App\Models\Specialty;
use App\Models\Doctor;
use App\Models\User;
use Tests\TestCase;

class SpecialtyModelTest extends TestCase
{
    /**
     * Test specialty can be created with name
     */
    public function test_specialty_can_be_created_with_name(): void
    {
        $specialty = Specialty::create(['name' => 'Cardiology']);

        $this->assertNotNull($specialty->id);
        $this->assertEquals('Cardiology', $specialty->name);
    }

    /**
     * Test specialty belongs to many doctors
     */
    public function test_specialty_belongs_to_many_doctors(): void
    {
        $specialty = Specialty::create(['name' => 'Neurology']);

        $user = User::create([
            'name' => 'Dr. Neurologist',
            'email' => 'neuro@example.com',
            'password' => 'password123',
        ]);

        $doctor = Doctor::create(['user_id' => $user->id]);
        $specialty->doctors()->attach($doctor->id);

        $this->assertTrue($specialty->doctors()->where('id', $doctor->id)->exists());
    }

    /**
     * Test specialty filter by name
     */
    public function test_specialty_scope_filter_by_name(): void
    {
        Specialty::create(['name' => 'Cardiology']);
        Specialty::create(['name' => 'Neurology']);
        Specialty::create(['name' => 'Pediatrics']);

        $results = Specialty::filterByName('Cardio')->get();

        $this->assertEquals(1, $results->count());
        $this->assertEquals('Cardiology', $results->first()->name);
    }

    /**
     * Test specialty filter by name with empty string
     */
    public function test_specialty_scope_filter_by_name_with_empty_string(): void
    {
        Specialty::create(['name' => 'Surgery']);
        Specialty::create(['name' => 'Oncology']);

        $results = Specialty::filterByName('')->get();

        $this->assertGreaterThanOrEqual(2, $results->count());
    }

    /**
     * Test specialty ordered by name
     */
    public function test_specialty_scope_ordered_by_name(): void
    {
        Specialty::create(['name' => 'Cardiology']);
        Specialty::create(['name' => 'Anesthesiology']);
        Specialty::create(['name' => 'Dermatology']);

        $results = Specialty::orderedByName()->get();

        $this->assertEquals('Anesthesiology', $results->first()->name);
        $this->assertEquals('Dermatology', $results->last()->name);
    }

    /**
     * Test specialty does not have timestamps
     */
    public function test_specialty_does_not_have_timestamps(): void
    {
        $specialty = Specialty::create(['name' => 'Urology']);

        $this->assertNull($specialty->created_at);
        $this->assertNull($specialty->updated_at);
    }

    /**
     * Test specialty can be updated
     */
    public function test_specialty_can_be_updated(): void
    {
        $specialty = Specialty::create(['name' => 'Original']);
        $specialty->update(['name' => 'Updated']);

        $this->assertEquals('Updated', $specialty->fresh()->name);
    }

    /**
     * Test multiple specialties can have the same doctor
     */
    public function test_multiple_specialties_for_same_doctor(): void
    {
        $user = User::create([
            'name' => 'Dr. Multi Specialist',
            'email' => 'multi@example.com',
            'password' => 'password123',
        ]);

        $doctor = Doctor::create(['user_id' => $user->id]);

        $specialty1 = Specialty::create(['name' => 'Internal Medicine']);
        $specialty2 = Specialty::create(['name' => 'Infectious Disease']);

        $doctor->specialties()->attach([$specialty1->id, $specialty2->id]);

        $this->assertEquals(2, $doctor->specialties()->count());
    }
}
