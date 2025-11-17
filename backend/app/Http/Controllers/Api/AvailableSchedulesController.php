<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AvailableSchedule;
use Illuminate\Http\Request;
use Carbon\Carbon;

class AvailableSchedulesController extends Controller
{
    
    public function index(Request $request)
    {
        $filters = $request->only(['doctor_id', 'specialty_id', 'clinic_id', 'schedule_id', 'from_date', 'to_date']);
        $schedules = AvailableSchedule::filter($filters);

        return response()->json([
            'count' => $schedules->count(),
            'data' => $schedules
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        $startDate = Carbon::parse($request->start_date);
        $endDate = Carbon::parse($request->end_date);

        $doctorId = $request->user()->doctor->id;

        
        $generatedSchedules = AvailableSchedule::generateSchedules($startDate, $endDate, $doctorId);

        return response()->json(['message' => 'Horarios generados exitosamente','data' => $generatedSchedules]);
    }

}
