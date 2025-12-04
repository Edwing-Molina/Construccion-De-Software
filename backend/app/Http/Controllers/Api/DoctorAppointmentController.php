<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreAppointmentRequest;
use App\Models\Appointment;
use App\Models\Doctor;
use App\Enums\AppointmentStatus;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\Rule;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;



class DoctorAppointmentController extends Controller
{
    use AuthorizesRequests;
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->hasRole('doctor')) {
            $doctorId = $user->doctor->id ?? null;

            if (!$doctorId) {
                return response()->json(['message' => 'No autorizado.'], 403);
            }
        } else {
            return response()->json(['message' => 'No autorizado.'], 403);
        }

        $query = Appointment::query()
            ->whereHas('availableSchedule', function ($query) use ($doctorId) {
                $query->where('doctor_id', $doctorId);
            });


        if ($request->has('status')) {
            $query->where('status', $request->query('status'));
            Log::info("Filtrando por estado.", ['status' => $request->query('status')]);
        }

        if ($request->has('from_date') && $request->has('to_date')) {
            $query->whereHas('availableSchedule', function ($query) use ($request) {
                $query->whereBetween('date', [$request->query('from_date'), $request->query('to_date')]);
            });
        }

        $query->with(['availableSchedule', 'patient.user']);

        $appointments = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'count' => $appointments->count(),
            'data' => $appointments,
        ]);
    }

    public function update(Request $request, $appointment_id)
    {
        $doctor = Auth::user()->doctor;

        if (!$doctor) {
            return response()->json(['message' => 'No autorizado.'], 403);
        }

        $appointment = Appointment::where('id', $appointment_id)
            ->whereHas('availableSchedule', function ($query) use ($doctor) {
                $query->where('doctor_id', $doctor->id);
            })
            ->first();

        if (!$appointment) {
            return response()->json(['message' => 'Cita no encontrada o no pertenece al doctor.'], 404);
        }

        if ($appointment->status === AppointmentStatus::Completado) {
            return response()->json(['message' => 'La cita ya está completada.'], 400);
        }

        $appointment->status = AppointmentStatus::Completado;
        $appointment->save();

        return response()->json([
            'message' => 'Cita marcada como completada.',
            'appointment' => $appointment
        ]);
    }

}
