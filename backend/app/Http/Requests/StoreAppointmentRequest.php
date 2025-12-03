<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Auth;
use App\Models\Doctor;
use App\Models\Specialty;
use Carbon\Carbon;

class StoreAppointmentRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return Auth::check();
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
public function rules(): array
    {
        return [
            'doctor_id' => [
                'required',
                'integer',
                'exists:users,id',
                function ($attribute, $value, $fail) {
                    $doctorUser = Doctor::where('user_id', $value)->first();

                    if (!$doctorUser || !$doctorUser->user->hasRole('doctor')) {
                        $fail('El doctor seleccionado no es válido o no está disponible.');
                    }
                },
            ],
            'specialty_id' => [
                'required',
                'integer',
                'exists:specialtys,id',
            ],
            'appointment_date' => [
                'required',
                'date_format:Y-m-d',
                'after_or_equal:today',
            ],
            'appointment_time' => [
                'required',
                'date_format:H:i',
            ],
        ];
    }

    /**
     * mensajes de error por algun error en la validacion
     */
    public function messages(): array
    {
        return [
            'doctor_id.required' => 'Debe seleccionar un doctor.',
            'doctor_id.integer' => 'El ID del doctor debe ser un número entero.',
            'doctor_id.exists' => 'El doctor seleccionado no es válido.',
            'specialty_id.required' => 'Debe seleccionar una especialidad.',
            'specialty_id.integer' => 'El ID de la especialidad debe ser un número entero.',
            'specialty_id.exists' => 'La especialidad seleccionada no es válida.',
            'appointment_date.required' => 'La fecha de la cita es obligatoria.',
            'appointment_date.date_format' => 'El formato de la fecha debe ser DD-MM-YYYY.',
            'appointment_date.after_or_equal' => 'La fecha de la cita no puede ser en el pasado.',
            'appointment_time.required' => 'La hora de la cita es obligatoria.',
            'appointment_time.date_format' => 'El formato de la hora debe ser HH:MM.',
        ];
    }

}
