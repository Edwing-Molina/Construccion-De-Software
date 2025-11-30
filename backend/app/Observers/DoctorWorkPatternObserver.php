<?php

namespace App\Observers;

use App\Models\DoctorWorkPattern;
use App\Models\AvailableSchedule;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class DoctorWorkPatternObserver
{
    /**
     * Handle the DoctorWorkPattern "created" event.
     *
     * @param  \App\Models\DoctorWorkPattern  $pattern
     * @return void
     */
    public function created(DoctorWorkPattern $pattern)
    {
        Log::info('Observer triggered for DoctorWorkPattern', ['pattern_id' => $pattern->id]);

        $startDate = Carbon::now();
        $endDate = Carbon::now()->addMonths(1); // Generar horarios para el próximo mes

        AvailableSchedule::generateSchedules($startDate, $endDate, $pattern->doctor_id);
    }
}
