<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;


class AvailableSchedule extends Model
{
    use SoftDeletes;

    protected $fillable = [
    'doctor_id',
    'clinic_id',
    'date',
    'start_time',
    'end_time',
    'available'];

    public function doctor()
    {
        return $this->belongsTo(Doctor::class);
    }

    public function clinic()
    {
        return $this->belongsTo(Clinic::class);
    }

    public function cite()
    {
        return $this->hasOne(Appointment::class);
    }

    public static function generateSchedules(Carbon $startDate, Carbon $endDate, $doctorId)
    {
        $workPatterns = DoctorWorkPattern::where('is_active', true)
            ->where('doctor_id', $doctorId)
            ->get();

        $generated = [];

        foreach ($workPatterns as $pattern) {
            $currentDate = $startDate->copy();

            while ($currentDate <= $endDate) {
                $currentDay = $currentDate->format('l');

                // Obtener valor string si day_of_week es enum
                $patternDay = $pattern->day_of_week instanceof \BackedEnum
                    ? $pattern->day_of_week->value
                    : $pattern->day_of_week;

                // Validar rango efectivo del patrón
                if (
                    $currentDate->lt(Carbon::parse($pattern->start_date_effective)) ||
                    ($pattern->end_date_effective && $currentDate->gt(Carbon::parse($pattern->end_date_effective)))
                ) {
                    $currentDate->addDay();
                    continue;
                }

                if ($currentDay === $patternDay) {
                    $slotStart = Carbon::parse($pattern->start_time_pattern->format('H:i:s'));
                    $endTime = Carbon::parse($pattern->end_time_pattern->format('H:i:s'));

                    while ($slotStart->lt($endTime)) {
                        $slotEnd = $slotStart->copy()->addMinutes($pattern->slot_duration_minutes);

                        $schedule = AvailableSchedule::firstOrCreate([
                            'doctor_id' => $pattern->doctor_id,
                            'clinic_id' => $pattern->clinic_id,
                            'date' => $currentDate->toDateString(),
                            'start_time' => $slotStart->format('H:i:s'),
                        ], [
                            'end_time' => $slotEnd->format('H:i:s'),
                            'available' => true,
                        ]);

                        $generated[] = $schedule;

                        $slotStart->addMinutes($pattern->slot_duration_minutes);
                    }
                }

                $currentDate->addDay();
            }
        }

        return $generated;
    }

    public static function filter($filters)
    {
        $query = self::query()->where('available', true);

        if (isset($filters['doctor_id'])) {
            $query->where('doctor_id', $filters['doctor_id']);
        }

        if (isset($filters['specialty_id'])) {
            $query->whereHas('doctor.specialties', function ($q) use ($filters) {
                $q->where('id', $filters['specialty_id']);
            });
        }

        if (isset($filters['clinic_id'])) {
            $query->whereHas('doctor.clinics', function ($q) use ($filters) {
                $q->where('id', $filters['clinic_id']);
            });
        }

        if (isset($filters['schedule_id'])) {
            $query->where('id', $filters['schedule_id']);
        }

        if (isset($filters['from_date'])) {
            $query->where('date', '>=', $filters['from_date']);
        }

        if (isset($filters['to_date'])) {
            $query->where('date', '<=', $filters['to_date']);
        }

        return $query->orderBy('date')->orderBy('start_time')->get();
    }
}

