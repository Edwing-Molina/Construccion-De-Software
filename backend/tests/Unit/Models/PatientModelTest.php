<?php

namespace Tests\Unit\Models;

use App\Models\Patient;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PatientModelTest extends TestCase
{
    use RefreshDatabase;

    private User $patientUser;
    private Patient $patient;

    protected function setUp(): void
    {
        parent::setUp();

        $this->patientUser = User::factory()->withPatient([
            'birth' => '1985-06-15',
            'blood_type' => 'O+',
            'emergency_contact_name' => 'María Mendez',
            'emergency_contact_phone' => '+52-555-0123',
            'nss_number' => 'NSS123456789',
        ])->create();

        $this->patient = $this->patientUser->patient;
    }

    /**
     * Test patient belongs to user
     */
    public function test_patient_belongs_to_user(): void
    {
        $this->assertTrue($this->patient->user()->exists());
        $this->assertEquals($this->patientUser->id, $this->patient->user->id);
    }

    /**
     * Test patient can be created with all fillable fields
     */
    public function test_patient_can_be_created_with_all_fields(): void
    {
        $this->assertNotNull($this->patient->id);
        $this->assertEquals('1985-06-15', $this->patient->birth->format('Y-m-d'));
        $this->assertEquals('O+', $this->patient->blood_type);
        $this->assertEquals('María Mendez', $this->patient->emergency_contact_name);
    }

    /**
     * Test patient can be created with minimal required fields
     */
    public function test_patient_can_be_created_with_minimal_fields(): void
    {
        $user = User::factory()->withPatient()->create();
        $patient = $user->patient;

        $this->assertNotNull($patient->id);
        $this->assertEquals($user->id, $patient->user_id);
    }

    /**
     * Test patient uses soft deletes
     */
    public function test_patient_uses_soft_deletes(): void
    {
        $this->patient->delete();

        $this->assertSoftDeleted($this->patient);
    }

    /**
     * Test patient with different blood types
     */
    public function test_patient_with_different_blood_types(): void
    {
        $bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

        foreach ($bloodTypes as $bloodType) {
            $user = User::factory()->withPatient(['blood_type' => $bloodType])->create();
            $patient = $user->patient;

            $this->assertEquals($bloodType, $patient->blood_type);
        }
    }

    /**
     * Test patient can be updated
     */
    public function test_patient_can_be_updated(): void
    {
        $this->patient->update([
            'emergency_contact_name' => 'Juan Mendez',
            'blood_type' => 'AB-',
        ]);

        $updated = $this->patient->fresh();
        $this->assertEquals('Juan Mendez', $updated->emergency_contact_name);
        $this->assertEquals('AB-', $updated->blood_type);
    }

    /**
     * Test patient can be retrieved with user relationship
     */
    public function test_patient_with_user_relationship(): void
    {
        $patientWithUser = Patient::with('user')->find($this->patient->id);

        $this->assertNotNull($patientWithUser->user);
        $this->assertEquals($this->patientUser->id, $patientWithUser->user->id);
    }
}
