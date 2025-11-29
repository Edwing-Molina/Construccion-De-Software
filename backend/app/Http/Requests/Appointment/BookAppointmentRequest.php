<?php

declare(strict_types=1);

namespace App\Http\Requests\Appointment;

use Illuminate\Foundation\Http\FormRequest;

final class BookAppointmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'available_schedule_id' => [
                'required',
                'integer',
                'exists:available_schedules,id',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'available_schedule_id.required' => 'Debe seleccionar un horario disponible para la cita.',
            'available_schedule_id.integer' => 'El identificador del horario debe ser un número válido.',
            'available_schedule_id.exists' => 'El horario seleccionado no existe en el sistema.',
        ];
    }


    public function attributes(): array
    {
        return [
            'available_schedule_id' => 'horario disponible',
        ];
    }
}
