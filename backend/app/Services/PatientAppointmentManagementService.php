<?php

declare(strict_types=1);

namespace App\Services;

use App\Enums\AppointmentStatus;
use App\Models\Appointment;
use App\Models\AvailableSchedule;
use App\Models\Patient;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

final class PatientAppointmentManagementService
{
    private const MINIMUM_HOURS_BEFORE_CANCELLATION = 24;

    /**
     * Retrieve paginated appointments for a patient with optional filters.
     */
    public function retrieveAppointmentsForPatient(
        User $authenticatedUser, 
        array $filterCriteria, 
        int $itemsPerPage
    ): LengthAwarePaginator {
        $patientRecord = $this->findPatientRecordByUser($authenticatedUser);

        return Appointment::where('patient_id', $patientRecord->id)
            ->applyStatusFilter($filterCriteria['status'] ?? null)
            ->applyDoctorFilter($filterCriteria['doctor_id'] ?? null)
            ->applySpecialtyFilter($filterCriteria['specialty_id'] ?? null)
            ->applyDateRangeFilter($filterCriteria['from_date'] ?? null, $filterCriteria['to_date'] ?? null)
            ->with([
                'availableSchedule.doctor.user',
                'availableSchedule.doctor.specialties',
            ])
            ->orderByDesc('created_at')
            ->paginate($itemsPerPage);
    }

    /**
     * Book a new appointment for a patient with an available schedule.
     */
    public function bookAppointmentForPatient(
        User $authenticatedUser, 
        int $selectedScheduleId
    ): Appointment {
        $patientRecord = $this->findPatientRecordByUser($authenticatedUser);
        $availableScheduleSlot = $this->findAvailableScheduleById($selectedScheduleId);

        return DB::transaction(function () use ($patientRecord, $availableScheduleSlot) {
            $this->ensureScheduleSlotIsAvailable($availableScheduleSlot);
            $this->ensureScheduleSlotIsNotAlreadyBooked($availableScheduleSlot);
            $this->ensureScheduleSlotIsInFuture($availableScheduleSlot);

            $newAppointmentRecord = Appointment::create([
                'patient_id' => $patientRecord->id,
                'available_schedule_id' => $availableScheduleSlot->id,
                'status' => AppointmentStatus::Pendiente->value,
            ]);

            $availableScheduleSlot->markAsUnavailable();

            return $newAppointmentRecord->load([
                'availableSchedule.doctor.user',
                'availableSchedule.doctor.specialties',
            ]);
        });
    }

    /**
     * Cancel a patient's appointment if all conditions are met.
     */
    public function cancelPatientAppointment(
        User $authenticatedUser, 
        int $appointmentIdentifier
    ): Appointment {
        $patientRecord = $this->findPatientRecordByUser($authenticatedUser);
        $appointmentToCancel = $this->findAppointmentBelongingToPatient($patientRecord, $appointmentIdentifier);

        return DB::transaction(function () use ($appointmentToCancel) {
            $this->ensureAppointmentIsNotAlreadyCancelled($appointmentToCancel);
            $this->ensureAppointmentIsNotAlreadyCompleted($appointmentToCancel);
            $this->ensureCancellationIsWithinAllowedTimeframe($appointmentToCancel);

            $appointmentToCancel->markAsCancelled();
            $appointmentToCancel->availableSchedule->markAsAvailable();

            return $appointmentToCancel->fresh([
                'availableSchedule.doctor.user',
                'availableSchedule.doctor.specialties',
            ]);
        });
    }

    /**
     * Find patient record associated with the authenticated user.
     */
    private function findPatientRecordByUser(User $authenticatedUser): Patient
    {
        $patientRecord = Patient::where('user_id', $authenticatedUser->id)->first();

        if (!$patientRecord) {
            throw new \RuntimeException('No se encontró un registro de paciente para este usuario.');
        }

        return $patientRecord;
    }

    /**
     * Find available schedule slot by its identifier.
     */
    private function findAvailableScheduleById(int $scheduleIdentifier): AvailableSchedule
    {
        $scheduleSlot = AvailableSchedule::with('doctor')->find($scheduleIdentifier);

        if (!$scheduleSlot) {
            throw new \RuntimeException('El horario seleccionado no fue encontrado en el sistema.');
        }

        return $scheduleSlot;
    }

    /**
     * Find appointment that belongs to the specified patient.
     */
    private function findAppointmentBelongingToPatient(
        Patient $patientRecord, 
        int $appointmentIdentifier
    ): Appointment {
        $appointmentRecord = Appointment::where('id', $appointmentIdentifier)
            ->where('patient_id', $patientRecord->id)
            ->with('availableSchedule')
            ->first();

        if (!$appointmentRecord) {
            throw new \RuntimeException('La cita no fue encontrada o no pertenece a este paciente.');
        }

        return $appointmentRecord;
    }

    /**
     * Ensure that the schedule slot is marked as available for booking.
     */
    private function ensureScheduleSlotIsAvailable(AvailableSchedule $scheduleSlot): void
    {
        if (!$scheduleSlot->available) {
            throw new \InvalidArgumentException('El horario seleccionado no está disponible para reservar.');
        }
    }

    /**
     * Ensure that the schedule slot has not been booked by another patient.
     */
    private function ensureScheduleSlotIsNotAlreadyBooked(AvailableSchedule $scheduleSlot): void
    {
        $isAlreadyBookedByAnotherPatient = Appointment::where('available_schedule_id', $scheduleSlot->id)
            ->whereIn('status', [
                AppointmentStatus::Pendiente->value,
                AppointmentStatus::Completado->value,
            ])
            ->exists();

        if ($isAlreadyBookedByAnotherPatient) {
            throw new \InvalidArgumentException('El horario seleccionado ya ha sido reservado por otro paciente.');
        }
    }

    /**
     * Ensure that the schedule slot is in the future (not in the past).
     */
    private function ensureScheduleSlotIsInFuture(AvailableSchedule $scheduleSlot): void
    {
        $scheduleDateTime = Carbon::parse(
            $scheduleSlot->date . ' ' . $scheduleSlot->start_time
        );

        if ($scheduleDateTime->isPast()) {
            throw new \InvalidArgumentException('No se pueden crear citas para horarios que ya han pasado.');
        }
    }

    /**
     * Ensure that the appointment is not already cancelled.
     */
    private function ensureAppointmentIsNotAlreadyCancelled(Appointment $appointmentRecord): void
    {
        if ($appointmentRecord->status === AppointmentStatus::Cancelada->value) {
            throw new \InvalidArgumentException('Esta cita ya ha sido cancelada previamente.');
        }
    }

    /**
     * Ensure that the appointment is not already completed.
     */
    private function ensureAppointmentIsNotAlreadyCompleted(Appointment $appointmentRecord): void
    {
        if ($appointmentRecord->status === AppointmentStatus::Completado->value) {
            throw new \InvalidArgumentException('No se puede cancelar una cita que ya ha sido completada.');
        }
    }

    /**
     * Ensure cancellation is at least 24 hours before the scheduled time.
     */
    private function ensureCancellationIsWithinAllowedTimeframe(Appointment $appointmentRecord): void
    {
        $scheduledDateTime = Carbon::parse(
            $appointmentRecord->availableSchedule->date . ' ' . 
            $appointmentRecord->availableSchedule->start_time
        );
        
        $hoursUntilScheduledAppointment = Carbon::now()->diffInHours($scheduledDateTime, false);

        if ($hoursUntilScheduledAppointment < self::MINIMUM_HOURS_BEFORE_CANCELLATION) {
            throw new \InvalidArgumentException(
                sprintf(
                    'No se puede cancelar la cita. Debe cancelarla al menos %d horas antes de la fecha programada.',
                    self::MINIMUM_HOURS_BEFORE_CANCELLATION
                )
            );
        }
    }
}