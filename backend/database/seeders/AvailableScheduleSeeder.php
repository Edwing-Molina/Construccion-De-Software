<?php

namespace Database\Seeders;

use App\Models\Doctor;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Carbon\Carbon;
use App\Models\DoctorWorkPattern;
use App\Models\AvailableSchedule;
use App\Models\Clinic;

class AvailableScheduleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $startDate = Carbon::today();
        $endDate = Carbon::today()->addDays(30);

        $this->command->info("--- Iniciando AvailableScheduleSeeder ---");
        $this->command->info("Generando horarios desde {$startDate->toDateString()} hasta {$endDate->toDateString()}...");

        $workPatterns = DoctorWorkPattern::where('is_active', true)
            ->where('doctor_id', 1)
            ->where('clinic_id', 1)
            ->get();

        if ($workPatterns->isEmpty()) {
            $this->command->warn('No se encontraron patrones de trabajo activos. No se generarán horarios disponibles.');
            return;
        }

        $totalSchedulesCreated = 0;

        foreach ($workPatterns as $pattern) {
            $doctor = Doctor::find($pattern->doctor_id);
            $clinic = Clinic::find($pattern->clinic_id);

            $doctorName = $doctor ? $doctor->user->name : 'Desconocido'; 
            $clinicName = $clinic ? $clinic->name : 'Desconocida';

            $this->command->info("Procesando patrón para Doctor: {$doctorName} (ID: {$pattern->doctor_id}), Clínica: {$clinicName} (ID: {$pattern->clinic_id}), Día: {$pattern->day_of_week->name}");

            $currentDate = $startDate->copy();

            while ($currentDate->lte($endDate)) {

                if ($currentDate->format('l') === $pattern->day_of_week->value) {
                    $slotStartTime = Carbon::parse($pattern->start_time_pattern);
                    $slotEndTime = Carbon::parse($pattern->end_time_pattern);

                    while ($slotStartTime->lt($slotEndTime)) {
                        $currentSlotEnd = $slotStartTime->copy()->addMinutes($pattern->slot_duration_minutes);

                        if ($currentSlotEnd->lte($slotEndTime)) {

                            AvailableSchedule::firstOrCreate(
                                [
                                    'doctor_id' => $pattern->doctor_id,
                                    'clinic_id' => $pattern->clinic_id,
                                    'date' => $currentDate->toDateString(),
                                    'start_time' => $slotStartTime->toTimeString(),
                                    'end_time' => $currentSlotEnd->toTimeString(),
                                ],
                                [
                                    'available' => true,
                                ]
                            );
                            $totalSchedulesCreated++;
                        }
                        $slotStartTime->addMinutes($pattern->slot_duration_minutes);
                    }
                }
                $currentDate->addDay();
            }
        }
        $this->command->info("--- Generación de horarios disponibles completada. Total creados/actualizados: {$totalSchedulesCreated} ---");
    }
}
