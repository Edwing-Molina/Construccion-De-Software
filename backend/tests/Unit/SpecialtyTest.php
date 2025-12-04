<?php

declare(strict_types=1);

namespace Tests\Unit\Models;

use App\Models\Specialty;
use App\Models\Doctor;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class SpecialtyTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_create_specialty_with_name(): void
    {
        $specialty = Specialty::factory()->create(['name' => 'Neurología']);

        $this->assertDatabaseHas('specialties', [
            'name' => 'Neurología'
        ]);
    }

    public function test_can_list_all_specialties_ordered_alphabetically(): void
    {
        Specialty::factory()->create(['name' => 'Neurología']);
        Specialty::factory()->create(['name' => 'Cardiología']);
        Specialty::factory()->create(['name' => 'Dermatología']);

        $specialties = Specialty::orderBy('name', 'asc')->get();

        $this->assertEquals('Cardiología', $specialties[0]->name);
        $this->assertEquals('Dermatología', $specialties[1]->name);
        $this->assertEquals('Neurología', $specialties[2]->name);
    }

    public function test_can_show_specific_specialty_details(): void
    {
        $specialty = Specialty::factory()->create(['name' => 'Neurología']);

        $found = Specialty::find($specialty->id);

        $this->assertNotNull($found);
        $this->assertEquals('Neurología', $found->name);
    }

    public function test_can_search_specialties_by_partial_name(): void
    {
        Specialty::factory()->create(['name' => 'Cardiología']);
        Specialty::factory()->create(['name' => 'Cardiología Pediátrica']);
        Specialty::factory()->create(['name' => 'Dermatología']);

        $specialties = Specialty::where('name', 'like', '%cardio%')->get();

        $this->assertCount(2, $specialties);
    }

    public function test_search_is_case_insensitive(): void
    {
        Specialty::factory()->create(['name' => 'Cardiología']);

        $uppercase = Specialty::whereRaw('LOWER(name) LIKE ?', ['%cardio%'])->get();
        $lowercase = Specialty::whereRaw('LOWER(name) LIKE ?', ['%cardio%'])->get();

        $this->assertCount(1, $uppercase);
        $this->assertCount(1, $lowercase);
    }

    public function test_search_returns_empty_when_no_matching_results(): void
    {
        Specialty::factory()->create(['name' => 'Cardiología']);

        $specialties = Specialty::where('name', 'like', '%noexiste%')->get();

        $this->assertTrue($specialties->isEmpty());
    }

    public function test_search_with_empty_string(): void
    {
        $specialties = Specialty::where('name', 'like', '%' . '' . '%')->get();

        $this->assertIsObject($specialties);
    }

    public function test_search_with_long_string(): void
    {
        $longString = str_repeat('a', 256);

        $specialties = Specialty::where('name', 'like', '%' . $longString . '%')->get();

        $this->assertTrue($specialties->isEmpty());
    }

    public function test_specialty_not_found_returns_null(): void
    {
        $specialty = Specialty::find(999);

        $this->assertNull($specialty);
    }

    public function test_search_results_are_ordered_alphabetically(): void
    {
        Specialty::factory()->create(['name' => 'Neurología']);
        Specialty::factory()->create(['name' => 'Cardiología']);
        Specialty::factory()->create(['name' => 'Dermatología']);

        $specialties = Specialty::where('name', 'like', '%logía%')
            ->orderBy('name', 'asc')
            ->get();

        $this->assertEquals('Cardiología', $specialties[0]->name);
        $this->assertEquals('Dermatología', $specialties[1]->name);
        $this->assertEquals('Neurología', $specialties[2]->name);
    }

    public function test_specialty_belongs_to_many_doctors(): void
    {
        $specialty = Specialty::factory()->create(['name' => 'Cardiología']);
        $user = User::factory()->withDoctor()->create();
        $user->doctor->specialties()->attach($specialty->id);

        $specialty->refresh();

        $this->assertCount(1, $specialty->doctors);
        $this->assertEquals($user->doctor->id, $specialty->doctors[0]->id);
    }
}

