<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Enums\DayOfWeek;
use App\Models\AvailableSchedule;
use App\Models\Clinic;
use App\Models\Doctor;
use App\Models\DoctorWorkPattern;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WorkPatternsControllerTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private Doctor $doctor;
    private Clinic $clinic;

    protected function setUp(): void
    {
        parent::setUp();

        // Crea un usuario con rol doctor y su modelo Doctor asociado
        $this->user = User::factory()->create();
        // Asume que tienes roles; si no, ajusta la verificación de rol en el controlador

        $this->doctor = Doctor::factory()->create([
            'user_id' => $this->user->id,
        ]);

        $this->clinic = Clinic::factory()->create();
    }

    public function test_index_returns_403_when_no_doctor_associated(): void
    {
        $userWithoutDoctor = User::factory()->create();

        $response = $this->actingAs($userWithoutDoctor)
            ->getJson('/api/work-patterns');

        $response->assertStatus(403)
            ->assertJson(['message' => 'No autorizado.']);
    }

    public function test_index_returns_work_patterns_for_doctor(): void
    {
        DoctorWorkPattern::factory()->create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::MONDAY,
            'start_time_pattern' => '08:00',
            'end_time_pattern' => '12:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/work-patterns');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'message',
                'data' => [
                    [
                        'id',
                        'doctor_id',
                        'clinic_id',
                        'day_of_week',
                        'start_time_pattern',
                        'end_time_pattern',
                        'slot_duration_minutes',
                        'is_active',
                    ],
                ],
            ]);
    }

    public function test_store_returns_400_on_validation_exception(): void
    {
        // Envía un payload inválido para provocar el catch del validate()
        $payload = [
            'clinic_id' => null,
            'day_of_week' => 'InvalidDay',
            'start_time_pattern' => 'invalid',
            'end_time_pattern' => 'invalid',
            'slot_duration_minutes' => -1,
            'is_active' => 'not_boolean',
        ];

        $response = $this->actingAs($this->user)
            ->postJson('/api/work-patterns', $payload);

        $response->assertStatus(400)
            ->assertJson(['message' => 'Informacion requerida.']);
    }

    public function test_store_returns_403_when_no_doctor_associated(): void
    {
        $userWithoutDoctor = User::factory()->create();

        $payload = [
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::MONDAY->value,
            'start_time_pattern' => '08:00',
            'end_time_pattern' => '12:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
        ];

        $response = $this->actingAs($userWithoutDoctor)
            ->postJson('/api/work-patterns', $payload);

        $response->assertStatus(403)
            ->assertJson(['message' => 'No autorizado.']);
    }

    public function test_store_creates_work_pattern_successfully(): void
    {
        $payload = [
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::TUESDAY->value,
            'start_time_pattern' => '09:00',
            'end_time_pattern' => '13:00',
            'slot_duration_minutes' => 20,
            'is_active' => true,
        ];

        $response = $this->actingAs($this->user)
            ->postJson('/api/work-patterns', $payload);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'message',
                'data' => [
                    'id',
                    'doctor_id',
                    'clinic_id',
                    'day_of_week',
                    'start_time_pattern',
                    'end_time_pattern',
                    'slot_duration_minutes',
                    'is_active',
                ],
            ]);

        $this->assertDatabaseHas('doctor_work_patterns', [
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::TUESDAY->value,
            'is_active' => 1,
        ]);
    }

    public function test_update_returns_403_when_no_doctor_associated(): void
    {
        $userWithoutDoctor = User::factory()->create();

        $pattern = DoctorWorkPattern::factory()->create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::WEDNESDAY,
            'start_time_pattern' => '08:00',
            'end_time_pattern' => '12:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
            'start_date_effective' => Carbon::now()->toDateString(),
            'end_date_effective' => Carbon::now()->toDateString(),
        ]);

        $response = $this->actingAs($userWithoutDoctor)
            ->putJson("/api/work-patterns/{$pattern->id}", []);

        $response->assertStatus(403)
            ->assertJson(['message' => 'Doctor no encontrado para el usuario autenticado.']);
    }

    public function test_update_returns_404_when_pattern_not_found_or_not_belongs_to_doctor(): void
    {
        $otherDoctor = Doctor::factory()->create();
        $otherPattern = DoctorWorkPattern::factory()->create([
            'doctor_id' => $otherDoctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::THURSDAY,
            'start_time_pattern' => '10:00',
            'end_time_pattern' => '14:00',
            'slot_duration_minutes' => 25,
            'is_active' => true,
            'start_date_effective' => Carbon::now()->toDateString(),
            'end_date_effective' => Carbon::now()->toDateString(),
        ]);

        $response = $this->actingAs($this->user)
            ->putJson("/api/work-patterns/{$otherPattern->id}", []);

        $response->assertStatus(404)
            ->assertJson(['message' => 'Patrón de trabajo no encontrado o no pertenece al doctor autenticado.']);
    }

    public function test_update_deactivates_pattern_and_updates_schedules(): void
    {
        // Crea patrón activo del doctor
        $pattern = DoctorWorkPattern::factory()->create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'day_of_week' => DayOfWeek::FRIDAY,
            'start_time_pattern' => '08:00',
            'end_time_pattern' => '12:00',
            'slot_duration_minutes' => 30,
            'is_active' => true,
            'start_date_effective' => Carbon::now()->startOfWeek()->toDateString(),
            'end_date_effective' => Carbon::now()->endOfWeek()->toDateString(),
        ]);

        // Crea horarios disponibles que coincidan por día y rango de fechas
        $friday = Carbon::now()->startOfWeek()->addDays(4)->toDateString(); // Viernes
        $schedule = AvailableSchedule::factory()->create([
            'doctor_id' => $this->doctor->id,
            'clinic_id' => $this->clinic->id,
            'date' => $friday,
            'start_time' => '08:00',
            'available' => true,
        ]);

        $response = $this->actingAs($this->user)
            ->putJson("/api/work-patterns/{$pattern->id}", []);

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Patrón de trabajo desactivado exitosamente y horarios libres actualizados.',
            ]);

        $pattern->refresh();
        $schedule->refresh();

        $this->assertFalse((bool) $pattern->is_active);
        $this->assertFalse((bool) $schedule->available);
    }
}