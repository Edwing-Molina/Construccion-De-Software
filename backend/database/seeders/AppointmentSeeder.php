<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Patient;
use App\Models\AvailableSchedule;
use App\Models\Appointment;
use Illuminate\Support\Facades\Log;

class AppointmentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->command->info("--- Iniciando AppointmentSeeder ---");
        $patient = Patient::find(1);

        if (!$patient) {
            $this->command->warn('No se encontraron pacientes. No se crearán citas.');
            return;
        }

        $this->command->info("Paciente encontrado para crear citas: {$patient->user->name} (ID: {$patient->id})");

        $availableSchedules = AvailableSchedule::where('available', true)
                                              ->inRandomOrder() 
                                              ->limit(2)
                                              ->get();

        if ($availableSchedules->isEmpty()) {
            $this->command->warn('No se encontraron horarios disponibles para crear citas. Asegúrate de que AvailableScheduleSeeder haya generado horarios y que haya slots disponibles (available = true).');
            return;
        }

        $totalAppointmentsCreated = 0;

        foreach ($availableSchedules as $schedule) {
            try {
                if ($schedule->available) {
                    $appointment = Appointment::create([
                        'patient_id' => $patient->id,
                        'available_schedule_id' => $schedule->id,
                        'status' => 'pendiente',
                    ]);

                    $schedule->update(['available' => false]);

                    $this->command->info(
                        "Cita #{$appointment->id} creada para Paciente: {$patient->user->name} con Horario: {$schedule->date} {$schedule->start_time} (ID: {$schedule->id})"
                    );
                    $totalAppointmentsCreated++;
                } else {
                    $this->command->warn("El horario ID {$schedule->id} ya no estaba disponible antes de intentar crear la cita. Se saltó.");
                }
            } catch (\Exception $e) {
                $this->command->error("Error al crear cita para el horario ID {$schedule->id}: " . $e->getMessage());
                Log::error("AppointmentSeeder Error al crear cita: " . $e->getMessage(), ['schedule_id' => $schedule->id]);
            }
        }

        $this->command->info("--- Finalizado AppointmentSeeder. Total de citas creadas: {$totalAppointmentsCreated} ---");
    
    }
}
