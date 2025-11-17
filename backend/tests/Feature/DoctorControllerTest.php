<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Doctor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Clase de prueba para el DoctorController.
 * Sigue los estándares PSR-12 para el formato de código.
 */
class DoctorControllerTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Prueba que el método index devuelva una lista paginada de doctores
     * con los campos sensibles ocultos.
     */
    public function test_index_returns_paginated_doctors_with_hidden_fields(): void
    {
        // ARRANGE: Crear datos en la BD usando factories
        Doctor::factory()->create([
            'name' => 'Dr. Smith',
            'license_number' => 'L12345',
            'specialty_id' => 1,
            'clinic_id' => 10,
        ]);

        Doctor::factory()->create([
            'name' => 'Dr. Jones',
            'license_number' => 'L67890',
            'specialty_id' => 2,
            'clinic_id' => 20,
        ]);

        // ACT: Llamada al endpoint (filtrando por specialty_id = 1)
        $response = $this->getJson('/api/doctors?per_page=10&specialty_id=1');

        // ASSERT: Código HTTP OK
        $response->assertOk();

        // Estructura esperada del JSON
        $response->assertJsonStructure([
            'data' => [
                '*' => [
                    'id',
                    'name',
                    'specialty_id',
                    'clinic_id',
                ],
            ],
            'current_page',
            'per_page',
            'total',
        ]);

        // Verificar que los campos sensibles no estén presentes en cada item
        $data = $response->json('data');

        $this->assertNotEmpty($data);

        foreach ($data as $item) {
            $this->assertArrayNotHasKey('license_number', $item);
            $this->assertArrayNotHasKey('deleted_at', $item);
            $this->assertArrayNotHasKey('created_at', $item);
            $this->assertArrayNotHasKey('updated_at', $item);
        }

        // Verificar que al menos el doctor filtrado esté presente
        $response->assertJsonFragment([
            'name' => 'Dr. Smith',
            'specialty_id' => 1,
        ]);
    }
}