<?php

namespace App\Http\Controllers\Api;

use App\Models\Appointment;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use App\Enums\AppointmentStatus;
use Carbon\Carbon;

class PatientAppointmentController extends Controller
{
    /**
     * Mostrar citas del paciente autenticado con filtros.
     */
    public function index(Request $request)
    {
        $patient = $request->user();

        $filters = [
            'status'        => $request->input('status'),
            'doctor_id'     => $request->input('doctor_id'),
            'specialty_id'  => $request->input('specialty_id'),
            'from_date'     => $request->input('from_date'),
            'to_date'       => $request->input('to_date'),
        ];

        $perPage = $request->input('per_page', 10);

        $appointments = Appointment::where('patient_id', $patient->id)
            ->filterByStatus($filters['status'])
            ->filterByDoctor($filters['doctor_id'])
            ->filterBySpecialty($filters['specialty_id'])
            ->filterByDateRange($filters['from_date'], $filters['to_date'])
            ->with(['availableSchedule.doctor', 'patient'])
            ->paginate($perPage);

        return response()->json([
            'message' => 'Citas obtenidas correctamente',
            'data' => $appointments,
        ]);
    }

    /**
     * Crear una nueva cita para el paciente autenticado.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'available_schedule_id' => 'required|exists:available_schedules,id',
            'appointment_date'      => 'required|date',
        ]);

        $patient = $request->user();

        $appointment = Appointment::create([
            'patient_id'             => $patient->id,
            'doctor_id'              => null, // se obtiene mediante availableSchedule
            'available_schedule_id'  => $validated['available_schedule_id'],
            'appointment_date'       => $validated['appointment_date'],
            'status'                 => AppointmentStatus::Pendiente->value,
        ]);

        return response()->json([
            'message' => 'Cita agendada correctamente',
            'data' => $appointment,
        ], 201);
    }

    /**
     * Obtener los detalles de una cita específica del paciente.
     */
    public function show($id, Request $request)
    {
        $patient = $request->user();

        $appointment = Appointment::where('patient_id', $patient->id)
            ->with(['availableSchedule.doctor', 'patient'])
            ->findOrFail($id);

        return response()->json([
            'message' => 'Cita obtenida correctamente',
            'data' => $appointment,
        ]);
    }

    /**
     * Cancelar una cita con anticipación.
     */
    public function cancel($id, Request $request)
    {
        $patient = $request->user();

        $appointment = Appointment::where('patient_id', $patient->id)->findOrFail($id);

        // Validar que la cita esté todavía pendiente
        if ($appointment->status !== AppointmentStatus::Pendiente->value) {
            return response()->json([
                'message' => 'Solo se pueden cancelar citas pendientes.',
            ], 422);
        }

        // Validar que la cancelación sea con anticipación (mínimo 2 horas antes)
        $appointmentDate = Carbon::parse($appointment->appointment_date);
        $now = Carbon::now();

        if ($appointmentDate->diffInHours($now, false) >= -2) {
            return response()->json([
                'message' => 'Las citas solo pueden cancelarse con al menos 2 horas de anticipación.',
            ], 422);
        }

        // Marcar como cancelada
        $appointment->update([
            'status' => AppointmentStatus::Cancelada->value,
        ]);

        return response()->json([
            'message' => 'Cita cancelada correctamente.',
            'data' => $appointment,
        ]);
    }

    /**
     * Eliminar una cita (solo si está cancelada o no asistió).
     */
    public function destroy($id, Request $request)
    {
        $patient = $request->user();

        $appointment = Appointment::where('patient_id', $patient->id)->findOrFail($id);

        if ($appointment->status === AppointmentStatus::Pendiente->value) {
            return response()->json([
                'message' => 'No puedes eliminar una cita pendiente. Primero cancélala.',
            ], 422);
        }

        $appointment->delete();

        return response()->json([
            'message' => 'Cita eliminada correctamente.',
        ]);
    }
}
