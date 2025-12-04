<?php

namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\DoctorWorkPattern;
use Illuminate\Validation\Rule;
use App\Enums\DayOfWeek;
use Illuminate\Support\Facades\Auth;
use App\Models\AvailableSchedule;
use Carbon\Carbon;


class WorkPatternsController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();

        $doctor = $user->doctor;

        if (!$doctor) {
            return response()->json(['message' => 'No autorizado.'], 403);
        }

        $workPatterns = DoctorWorkPattern::forDoctor($doctor->id)
            ->with(['clinic'])
            ->get();

        return response()->json([
            'message' => 'Work patterns retrieved successfully.',
            'data' => $workPatterns
        ], 200);
    }

    public function store(Request $request)
    {
        try{
        $request->validate([
            'clinic_id'             => 'required|exists:clinics,id',
            'day_of_week'           => ['required', Rule::in(DayOfWeek::toArray())],
            'start_time_pattern'    => 'required|date_format:H:i',
            'end_time_pattern'      => 'required|date_format:H:i|after:start_time_pattern',
            'slot_duration_minutes' => 'required|integer|min:1',
            'is_active'             => 'required|boolean',
            'start_date_effective'  => 'nullable|date',
            'end_date_effective'    => 'nullable|date|after_or_equal:start_date_effective',
        ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Informacion requerida.'], 400);
        }

        $doctor = Auth::user()->doctor;

        if (!$doctor) {
            return response()->json(['message' => 'No autorizado.'], 403);
        }

        try {
            $pattern = DoctorWorkPattern::createWorkPattern([
                'doctor_id'             => $doctor->id,
                'clinic_id'             => $request->clinic_id,
                'day_of_week'           => $request->day_of_week,
                'start_time_pattern'    => $request->start_time_pattern,
                'end_time_pattern'      => $request->end_time_pattern,
                'slot_duration_minutes' => $request->slot_duration_minutes,
                'is_active'             => $request->is_active,
                'start_date_effective'  => $request->start_date_effective,
                'end_date_effective'    => $request->end_date_effective,
            ]);

            return response()->json([
                'message' => 'Patrón de trabajo registrado exitosamente.',
                'data'    => $pattern
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 400);
        }
    }


    public function update(Request $request, $id)
    {
        $user = $request->user();
        $doctor = $user->doctor;

        if (!$doctor) {
            return response()->json(['message' => 'Doctor no encontrado para el usuario autenticado.'], 403);
        }

        $workPattern = DoctorWorkPattern::where('id', $id)
            ->where('doctor_id', $doctor->id)
            ->first();

        if (!$workPattern) {
            return response()->json(['message' => 'Patrón de trabajo no encontrado o no pertenece al doctor autenticado.'], 404);
        }

        $workPattern->update(['is_active' => false]);

        // Cancelar horarios disponibles relacionados
        if (!$workPattern->start_date_effective) {
            return response()->json(['message' => 'Fecha de inicio no definida en el patrón de trabajo'], 400);
        }

        try {
            $startDate = Carbon::parse($workPattern->start_date_effective)->toDateString();
        } catch (\Exception $e) {
        
            return response()->json(['message' => 'Error al procesar fecha de inicio del patrón.'], 500);
        }

        try {
            $endDate = $workPattern->end_date_effective
                ? Carbon::parse($workPattern->end_date_effective)->toDateString()
                : $startDate;
        } catch (\Exception $e) {
            
            $endDate = $startDate;
        }

        $dayOfWeek = $workPattern->day_of_week;

        if ($dayOfWeek instanceof DayOfWeek) {
            $dayOfWeek = $dayOfWeek->value;
        }

        

        
        $horariosCancelados = AvailableSchedule::where('doctor_id', $doctor->id)
            ->where('clinic_id', $workPattern->clinic_id)
            ->whereBetween('date', [$startDate, $endDate])
            ->get()
            ->filter(function ($schedule) use ($dayOfWeek) {
                
                $scheduleDayOfWeek = Carbon::parse($schedule->date)->dayOfWeek;
                
                return $scheduleDayOfWeek == $dayOfWeek;
            })
            ->filter(function ($schedule) {
                
                return !$schedule->appointments()
                    ->whereNotIn('status', ['cancelada'])
                    ->exists();
            });

        $horariosCancelados->each(function ($schedule) {
            $schedule->update(['available' => false]);
        });

    

        return response()->json([
            'message' => 'Patrón de trabajo desactivado exitosamente y horarios libres actualizados.',
            'data' => $workPattern
        ], 200);
    }

}
