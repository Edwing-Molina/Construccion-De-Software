<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Patient;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class PatientTest extends TestCase
{
    use RefreshDatabase;

    public function test_patient_model_has_correct_fillable_fields(): void
    {
        $fillable = (new Patient())->getFillable();

        $expectedFields = [
            'user_id',
            'birth',
            'blood_type',
            'emergency_contact_name',
            'emergency_contact_phone',
            'nss_number',
        ];

        $this->assertEquals($expectedFields, $fillable);
    }

    public function test_patient_hides_sensitive_data(): void
    {
        $patient = Patient::factory()
            ->for(User::factory())
            ->create(['nss_number' => '12345678901']);

        $patientArray = $patient->toArray();

        $this->assertArrayNotHasKey('nss_number', $patientArray);
        $this->assertArrayNotHasKey('deleted_at', $patientArray);
    }

    public function test_birth_is_cast_to_date(): void
    {
        $patient = Patient::factory()
            ->for(User::factory())
            ->create(['birth' => '1990-05-15']);

        $this->assertInstanceOf(\Carbon\Carbon::class, $patient->birth);
    }

    public function test_patient_belongs_to_user(): void
    {
        $user = User::factory()->create();
        $patient = Patient::factory()->for($user)->create();

        $this->assertInstanceOf(User::class, $patient->user);
        $this->assertEquals($user->id, $patient->user->id);
    }

    public function test_can_filter_patients_by_search(): void
    {
        $user1 = User::factory()->create(['name' => 'Juan Pérez']);
        Patient::factory()->for($user1)->create();

        $user2 = User::factory()->create(['name' => 'María González']);
        Patient::factory()->for($user2)->create();

        $filteredPatients = Patient::filter(['search' => 'Juan'])->get();

        $this->assertCount(1, $filteredPatients);
    }

    public function test_can_filter_patients_by_blood_type(): void
    {
        Patient::factory()
            ->for(User::factory())
            ->create(['blood_type' => 'O+']);

        Patient::factory()
            ->for(User::factory())
            ->create(['blood_type' => 'A+']);

        $filteredPatients = Patient::filter(['blood_type' => 'O+'])->get();

        $this->assertCount(1, $filteredPatients);
        $this->assertEquals('O+', $filteredPatients->first()->blood_type);
    }

    public function test_soft_deletes_work(): void
    {
        $patient = Patient::factory()
            ->for(User::factory())
            ->create();

        $patient->delete();

        $this->assertSoftDeleted($patient);
        $this->assertNotNull($patient->fresh()->deleted_at);
    }
}
