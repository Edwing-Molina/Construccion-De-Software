<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use App\Models\Doctor;
use App\Models\Specialty;
use App\Models\Clinic;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DoctorControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_index_returns_paginated_doctors_with_hidden_fields(): void
    {
        // Crear usuario y doctor 1
        $user1 = User::create([
            'name' => 'Dr. Smith',
            'email' => 'smith@example.com',
            'password' => bcrypt('secret'),
        ]);

        $doctor1 = Doctor::create([
            'user_id' => $user1->id,
        ]);

        // Crear usuario y doctor 2
        $user2 = User::create([
            'name' => 'Dr. Jones',
            'email' => 'jones@example.com',
            'password' => bcrypt('secret'),
        ]);

        $doctor2 = Doctor::create([
            'user_id' => $user2->id,
        ]);

        // Crear especialidades y clínicas
        $specialty1 = Specialty::create(['name' => 'Cardiología']);
        $specialty2 = Specialty::create(['name' => 'Dermatología']);

        $clinic1 = Clinic::create(['name' => 'Clínica Norte']);
        $clinic2 = Clinic::create(['name' => 'Clínica Sur']);

        // Asociar relaciones (muchos a muchos) + office_number en pivot
        $doctor1->specialties()->attach($specialty1->id);
        $doctor1->clinics()->attach($clinic1->id, ['office_number' => '101']);

        $doctor2->specialties()->attach($specialty2->id);
        $doctor2->clinics()->attach($clinic2->id, ['office_number' => '202']);

        // Llamar endpoint filtrando por specialty_id del primero
        $response = $this->getJson('/api/doctors?per_page=10&specialty_id=' . $specialty1->id);

        $response->assertOk();

        // Validar estructura mínima
        $response->assertJsonStructure([
            'data' => [
                '*' => [
                    'id',
                    // Ajusta según lo que realmente devuelve tu recurso / transformación
                    'user' => ['name'],
                    'specialties',
                    'clinics',
                ],
            ],
        ]);

        $data = $response->json('data');
        $this->assertNotEmpty($data);

        // Verificar que aparece Dr. Smith
        $found = collect($data)->first(
            fn ($row) => $row['user']['name'] === 'Dr. Smith'
        );
        $this->assertNotNull($found);

        // Verificar que no se expone license_number si lo ocultas (solo si existe en el modelo)
        foreach ($data as $row) {
            $this->assertArrayNotHasKey('license_number', $row);
        }
    }
}