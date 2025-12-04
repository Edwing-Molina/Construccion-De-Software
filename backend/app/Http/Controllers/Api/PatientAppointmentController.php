<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Enums\AppointmentStatus;
use App\Models\Appointment;
use App\Models\Patient;
use Illuminate\Http\Request;
use App\Models\AvailableSchedule;
use Illuminate\Support\Facades\Auth;

use Carbon\Carbon;

class PatientAppointmentController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        
        $patient = Patient::where('user_id', $user->id)->first();

        if (!$patient) {
            return response()->json([
                'message' => 'Paciente no encontrado.',
                'status' => 'error'
            ], 404);
        }

        $query = Appointment::where('patient_id', $patient->id)
            ->filterByStatus($request->query('status'))
            ->filterByDoctor($request->query('doctor_id'))
            ->filterBySpecialty($request->query('specialty_id'))
            ->filterByDateRange($request->query('from_date'), $request->query('to_date'))
            ->with(['doctor.user', 'doctor.specialties', 'availableSchedule.clinic', 'patient.user']);

        $perPage = $request->get('per_page', 10);
        $appointments = $query->paginate($perPage);

        return response()->json([
            'message' => 'Citas obtenidas correctamente.',
            'data' => $appointments,
        ]);
    }


    public function store(Request $request)
    {
        $request->validate([
            'available_schedule_id' => 'required|exists:available_schedules,id',
        ]);

        $availableSchedule = AvailableSchedule::find($request->available_schedule_id);

        if (!$availableSchedule || !$availableSchedule->available) {
            return response()->json(['message' => 'El horario seleccionado no está disponible.'], 400);
        }

        $existingAppointment = Appointment::where('available_schedule_id', $availableSchedule->id)
                                          ->whereIn('status', [AppointmentStatus::Pendiente->value, AppointmentStatus::Completado->value]) // Usar valores del Enum
                                          ->exists();

        if ($existingAppointment) {
            return response()->json(['message' => 'El horario seleccionado ya está reservado.'], 400);
        }

        $patientUser = Auth::user();

        
        $patient = Patient::where('user_id', $patientUser->id)->first();
        if (!$patient) {
            return response()->json(['message' => 'Paciente no encontrado.'], 404);
        }

        $appointment = new Appointment();
        $appointment->patient_id = $patient->id;
        $appointment->available_schedule_id = $availableSchedule->id;
        $appointment->status = AppointmentStatus::Pendiente;

        $appointment->save();

        
        $availableSchedule->update(['available' => false]);

        return response()->json([
            'message' => 'Cita creada exitosamente.',
            'appointment' => $appointment
        ], 201);
    }

public function update(Request $request, $appointment_id)
    {
        
        
        $user = $request->user();

        $patient = Patient::where('user_id', $user->id)->first();
        if (!$patient) {
            return response()->json(['message' => 'Paciente no encontrado.'], 404);
        }

        $appointment = Appointment::where('id', $appointment_id)
            ->where('patient_id', $patient->id)
            ->with('availableSchedule')
            ->first();

        if (!$appointment) {
            return response()->json(['message' => 'Cita no encontrada o no pertenece al paciente.'], 404);
        }

        if ($appointment->status == AppointmentStatus::Cancelada) {
            return response()->json(['message' => 'La cita ya está cancelada.'], 400);
        }

        $date = $appointment->availableSchedule->date;
        $dateStr = $date instanceof Carbon ? $date->format('Y-m-d') : substr($date, 0, 10);
        $timeStr = substr(trim((string) $appointment->availableSchedule->start_time), 0, 8);
        
        $appointmentDateTime = Carbon::createFromFormat('Y-m-d H:i:s', "$dateStr $timeStr");
        
        $now = Carbon::now();
        $hoursUntilAppointment = $now->diffInHours($appointmentDateTime, false);

        if ($hoursUntilAppointment < 24) {
            return response()->json([
                'message' => 'No se puede cancelar la cita. Debe cancelarla al menos 24 horas antes de la fecha y hora programada.',
            ], 400);
        }

        $appointment->status = AppointmentStatus::Cancelada;
        $appointment->save();

        $appointment->availableSchedule->update(['available' => true]);

        return response()->json([
            'message' => 'Cita cancelada correctamente.',
            'data' => $appointment,
        ]);
    }


}
