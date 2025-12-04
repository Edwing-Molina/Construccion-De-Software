<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Carbon\Carbon;

final class AvailableSchedule extends Model
{
    use HasFactory;

    protected $fillable = [
        'doctor_id',
        'clinic_id', 
        'date',
        'start_time',
        'end_time',
        'available',
    ];

    protected $casts = [
        'date' => 'date',
        'available' => 'boolean',
    ];


    public function doctor(): BelongsTo
    {
        return $this->belongsTo(Doctor::class);
    }

    public function appointments(): HasMany
    {
        return $this->hasMany(Appointment::class);
    }


    public function markAsAvailable(): bool
    {
        return $this->update(['available' => true]);
    }

    public function markAsUnavailable(): bool
    {
        return $this->update(['available' => false]);
    }

    public function isAvailable(): bool
    {
        return $this->available === true;
    }

    public function isInFuture(): bool
    {
        $scheduleDateTime = Carbon::parse($this->date . ' ' . $this->start_time);
        return $scheduleDateTime->isFuture();
    }

    /**
     * Genera horarios disponibles basados en los patrones de trabajo del doctor
     */
    public static function generateSchedules(Carbon $startDate, Carbon $endDate, int $doctorId)
    {
        $doctor = Doctor::find($doctorId);
        
        if (!$doctor) {
            throw new \Exception('Doctor no encontrado');
        }

        $schedules = [];
        $currentDate = $startDate->copy();

        while ($currentDate->lte($endDate)) {
            
            $dayName = $currentDate->format('l'); 
            
            $workPatterns = DoctorWorkPattern::where('doctor_id', $doctorId)
                ->where('is_active', true)
                ->get()
                ->filter(function ($pattern) use ($dayName, $currentDate) {
                    
                    $patternDay = $pattern->day_of_week->value ?? $pattern->day_of_week;
                    
                    if ($patternDay !== $dayName) {
                        return false;
                    }

                    
                    if ($pattern->start_date_effective && $currentDate->lt($pattern->start_date_effective)) {
                        return false;
                    }

                    if ($pattern->end_date_effective && $currentDate->gt($pattern->end_date_effective)) {
                        return false;
                    }

                    return true;
                });

            foreach ($workPatterns as $pattern) {
                
                $startTimeStr = is_string($pattern->start_time_pattern) 
                    ? $pattern->start_time_pattern 
                    : $pattern->start_time_pattern->format('H:i:s');
                    
                $endTimeStr = is_string($pattern->end_time_pattern) 
                    ? $pattern->end_time_pattern 
                    : $pattern->end_time_pattern->format('H:i:s');

                
                $startTime = Carbon::createFromFormat('H:i:s', $startTimeStr);
                $endTime = Carbon::createFromFormat('H:i:s', $endTimeStr);
                $slotDuration = $pattern->slot_duration_minutes;

                $currentSlotStart = $startTime->copy();

                while ($currentSlotStart->copy()->addMinutes($slotDuration)->lte($endTime)) {
                    $currentSlotEnd = $currentSlotStart->copy()->addMinutes($slotDuration);

                    try {
                        $schedule = self::firstOrCreate([
                            'doctor_id' => $doctorId,
                            'clinic_id' => $pattern->clinic_id,
                            'date' => $currentDate->toDateString(),
                            'start_time' => $currentSlotStart->format('H:i:s'),
                            'end_time' => $currentSlotEnd->format('H:i:s'),
                        ], [
                            'available' => true,
                        ]);

                        $schedules[] = $schedule;
                    } catch (\Exception $e) {
                        
                    
                    }

                    $currentSlotStart = $currentSlotEnd;
                }
            }

            $currentDate->addDay();
        }

        return $schedules;
    }
}