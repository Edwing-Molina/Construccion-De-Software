<?php

declare(strict_types=1);

namespace App\Http\Requests\Profile;

use App\Enums\Genres;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

final class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            ...$this->basicUserRules(),
            ...$this->patientRules(),
            ...$this->doctorRules(),
            ...$this->specialtyRules(),
            ...$this->clinicRules(),
        ];
    }

    private function basicUserRules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'phone' => ['sometimes', 'string', 'max:20'],
        ];
    }

    private function patientRules(): array
    {
        return [
            'patient' => ['sometimes', 'array'],
            'patient.birth_date' => ['sometimes', 'date', 'before:today'],
            'patient.blood_type' => ['sometimes', 'string', 'max:5'],
            'patient.gender' => ['sometimes', Rule::in(Genres::toArray())],
            'patient.emergency_contact_name' => ['sometimes', 'string', 'max:100'],
            'patient.emergency_contact_phone' => ['sometimes', 'string', 'max:20'],
            'patient.nss_number' => ['sometimes', 'nullable', 'string', 'max:20'],
        ];
    }

    private function doctorRules(): array
    {
        return [
            'doctor' => ['sometimes', 'array'],
            'doctor.license_number' => ['sometimes', 'string', 'max:50'],
            'doctor.consultation_fee' => ['sometimes', 'numeric', 'min:0'],
        ];
    }

    private function specialtyRules(): array
    {
        return [
            'specialty_ids' => ['sometimes', 'array'],
            'specialty_ids.*' => ['integer', 'exists:specialties,id'],
        ];
    }

    private function clinicRules(): array
    {
        return [
            'clinics' => ['sometimes', 'array'],
            'clinics.*.clinic_id' => ['required', 'integer', 'exists:clinics,id'],
            'clinics.*.office_number' => ['nullable', 'string', 'max:20'],
        ];
    }

    public function messages(): array
    {
        return [
            'patient.gender.in' => 'El género proporcionado no es válido.',
            'specialty_ids.*.exists' => 'Una o más especialidades son inválidas.',
            'clinics.*.clinic_id.exists' => 'Una o más clínicas son inválidas.',
        ];
    }
}
