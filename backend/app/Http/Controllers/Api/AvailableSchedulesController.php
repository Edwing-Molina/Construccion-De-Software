<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AvailableSchedule;
use Illuminate\Http\Request;
use Carbon\Carbon;

class AvailableSchedulesController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    
    public function index(Request $request)
    {
        $query = AvailableSchedule::query();

        // Apply filters
        if ($request->has('doctor_id')) {
            $query->where('doctor_id', $request->doctor_id);
        }

        if ($request->has('clinic_id')) {
            $query->where('clinic_id', $request->clinic_id);
        }

        if ($request->has('from_date')) {
            $query->where('date', '>=', $request->from_date);
        }

        if ($request->has('to_date')) {
            $query->where('date', '<=', $request->to_date);
        }

        $schedules = $query->where('available', true)
            ->orderBy('date')
            ->orderBy('start_time')
            ->get();

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