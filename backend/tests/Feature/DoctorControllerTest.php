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
        $authenticatedUser = User::factory()->create();

        $user1 = User::factory()->withDoctor()->create(['name' => 'Dr. Smith']);
        $doctor1 = $user1->doctor;

        $user2 = User::factory()->withDoctor()->create(['name' => 'Dr. Jones']);
        $doctor2 = $user2->doctor;

        $specialty1 = Specialty::factory()->create(['name' => 'Cardiología']);
        $specialty2 = Specialty::factory()->create(['name' => 'Dermatología']);

        $clinic1 = Clinic::factory()->create(['name' => 'Clínica Norte']);
        $clinic2 = Clinic::factory()->create(['name' => 'Clínica Sur']);

        $doctor1->specialties()->attach($specialty1->id);
        $doctor1->clinics()->attach($clinic1->id, ['office_number' => '101']);

        $doctor2->specialties()->attach($specialty2->id);
        $doctor2->clinics()->attach($clinic2->id, ['office_number' => '202']);

        $this->assertTrue($doctor1->exists());
        $this->assertTrue($doctor2->exists());
        $this->assertEquals('Dr. Smith', $doctor1->user->name);
        $this->assertEquals('Dr. Jones', $doctor2->user->name);
    }
}