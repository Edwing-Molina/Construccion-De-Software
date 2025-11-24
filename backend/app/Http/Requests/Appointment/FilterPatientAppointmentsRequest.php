<?php

declare(strict_types=1);

namespace App\Http\Requests\Appointment;

use App\Enums\AppointmentStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

final class FilterPatientAppointmentsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'status' => [
                'sometimes', 
                'string', 
                Rule::in(AppointmentStatus::toArray())
            ],
            'doctor_id' => [
                'sometimes', 
                'integer', 
                'exists:doctors,id'
            ],
            'specialty_id' => [
                'sometimes', 
                'integer', 
                'exists:specialties,id'
            ],
            'from_date' => [
                'sometimes', 
                'date', 
                'before_or_equal:to_date'
            ],
            'to_date' => [
                'sometimes', 
                'date', 
                'after_or_equal:from_date'
            ],
            'per_page' => [
                'sometimes', 
                'integer', 
                'min:1', 
                'max:100'
            ],
        ];
    }

    public function getValidatedFilters(): array
    {
        return $this->only([
            'status',
            'doctor_id',
            'specialty_id',
            'from_date',
            'to_date',
        ]);
    }

    public function messages(): array
    {
        return [
            'status.in' => 'El estado de cita seleccionado no es válido.',
            'doctor_id.exists' => 'El doctor especificado no existe en el sistema.',
            'specialty_id.exists' => 'La especialidad especificada no existe en el sistema.',
            'from_date.before_or_equal' => 'La fecha de inicio debe ser anterior o igual a la fecha de fin.',
            'to_date.after_or_equal' => 'La fecha de fin debe ser posterior o igual a la fecha de inicio.',
            'per_page.min' => 'Debe solicitar al menos 1 elemento por página.',
            'per_page.max' => 'No puede solicitar más de 100 elementos por página.',
        ];
    }
}
