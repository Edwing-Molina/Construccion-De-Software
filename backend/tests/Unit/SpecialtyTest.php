<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Specialty;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class SpecialtyTest extends TestCase
{
    use RefreshDatabase;

    private User $authenticatedUser;

    protected function setUp(): void
    {
        parent::setUp();
        $this->authenticatedUser = User::factory()->create();
    }

    public function test_can_list_all_specialties_ordered_alphabetically(): void
    {
        Specialty::factory()->create(['name' => 'Neurología']);
        Specialty::factory()->create(['name' => 'Cardiología']);
        Specialty::factory()->create(['name' => 'Dermatología']);

        $response = $this->actingAs($this->authenticatedUser)
            ->getJson('/api/specialties');

        $response->assertOk()
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'name']
                ]
            ])
            ->assertJsonCount(3, 'data');

        // Verify alphabetical order
        $data = $response->json('data');
        $this->assertEquals('Cardiología', $data[0]['name']);
        $this->assertEquals('Dermatología', $data[1]['name']);
        $this->assertEquals('Neurología', $data[2]['name']);
    }

    public function test_can_show_specific_specialty_details(): void
    {
        $specialty = Specialty::factory()->create(['name' => 'Neurología']);

        $response = $this->actingAs($this->authenticatedUser)
            ->getJson("/api/specialties/{$specialty->id}");

        $response->assertOk()
            ->assertJsonStructure([
                'data' => ['id', 'name']
            ])
            ->assertJsonFragment(['name' => 'Neurología']);
    }

    public function test_can_search_specialties_by_partial_name(): void
    {
        Specialty::factory()->create(['name' => 'Cardiología']);
        Specialty::factory()->create(['name' => 'Cardiología Pediátrica']);
        Specialty::factory()->create(['name' => 'Dermatología']);

        $response = $this->actingAs($this->authenticatedUser)
            ->getJson('/api/specialties/search?search=cardio');

        $response->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonFragment(['name' => 'Cardiología'])
            ->assertJsonFragment(['name' => 'Cardiología Pediátrica']);
    }

    public function test_search_is_case_insensitive(): void
    {
        Specialty::factory()->create(['name' => 'Cardiología']);

        $responseUppercase = $this->actingAs($this->authenticatedUser)
            ->getJson('/api/specialties/search?search=CARDIO');

        $responseLowercase = $this->actingAs($this->authenticatedUser)
            ->getJson('/api/specialties/search?search=cardio');

        $responseUppercase->assertOk()->assertJsonCount(1, 'data');
        $responseLowercase->assertOk()->assertJsonCount(1, 'data');
    }

    public function test_search_returns_404_when_no_matching_results(): void
    {
        Specialty::factory()->create(['name' => 'Cardiología']);

        $response = $this->actingAs($this->authenticatedUser)
            ->getJson('/api/specialties/search?search=noexiste');

        $response->assertNotFound()
            ->assertJson([
                'message' => 'No se encontraron especialidades con ese criterio.',
                'data' => []
            ]);
    }

    public function test_search_requires_search_parameter(): void
    {
        $response = $this->actingAs($this->authenticatedUser)
            ->getJson('/api/specialties/search');

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['search']);
    }

    public function test_search_requires_non_empty_string(): void
    {
        $response = $this->actingAs($this->authenticatedUser)
            ->getJson('/api/specialties/search?search=');

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['search']);
    }

    public function test_search_validates_maximum_length(): void
    {
        $longString = str_repeat('a', 256); // 256 caracteres

        $response = $this->actingAs($this->authenticatedUser)
            ->getJson("/api/specialties/search?search={$longString}");

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['search']);
    }

    public function test_specialty_not_found_returns_404(): void
    {
        $response = $this->actingAs($this->authenticatedUser)
            ->getJson('/api/specialties/999');

        $response->assertNotFound();
    }

    public function test_search_results_are_ordered_alphabetically(): void
    {
        Specialty::factory()->create(['name' => 'Neurología']);
        Specialty::factory()->create(['name' => 'Cardiología']);
        Specialty::factory()->create(['name' => 'Dermatología']);

        $response = $this->actingAs($this->authenticatedUser)
            ->getJson('/api/specialties/search?search=logía');

        $response->assertOk();

        $data = $response->json('data');
        $this->assertEquals('Cardiología', $data[0]['name']);
        $this->assertEquals('Dermatología', $data[1]['name']);
        $this->assertEquals('Neurología', $data[2]['name']);
    }

    public function test_unauthenticated_user_cannot_access_specialties(): void
    {
        $response = $this->getJson('/api/specialties');

        $response->assertUnauthorized();
    }
}
