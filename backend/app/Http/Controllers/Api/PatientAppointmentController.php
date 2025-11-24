<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Appointment\BookAppointmentRequest;
use App\Http\Requests\Appointment\FilterPatientAppointmentsRequest;
use App\Http\Resources\AppointmentResource;
use App\Services\PatientAppointmentManagementService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class PatientAppointmentController extends Controller
{
    private const DEFAULT_APPOINTMENTS_PER_PAGE = 10;
    private const MINIMUM_APPOINTMENTS_PER_PAGE = 1;
    private const MAXIMUM_APPOINTMENTS_PER_PAGE = 100;

    public function __construct(
        private readonly PatientAppointmentManagementService $appointmentManagementService
    ) {}

    public function listPatientAppointments(FilterPatientAppointmentsRequest $request): JsonResponse
    {
        $authenticatedUser = $request->user();
        
        $paginatedPatientAppointments = $this->appointmentManagementService->retrieveAppointmentsForPatient(
            authenticatedUser: $authenticatedUser,
            filterCriteria: $request->getValidatedFilters(),
            itemsPerPage: $this->calculateItemsPerPage($request)
        );

        return $this->buildSuccessResponse(
            successMessage: 'Citas del paciente obtenidas correctamente.',
            responseData: AppointmentResource::collection($paginatedPatientAppointments)
        );
    }

    public function bookNewAppointment(BookAppointmentRequest $request): JsonResponse
    {
        $authenticatedUser = $request->user();

        $newlyCreatedAppointment = $this->appointmentManagementService->bookAppointmentForPatient(
            authenticatedUser: $authenticatedUser,
            selectedScheduleId: $request->validated('available_schedule_id')
        );

        return $this->buildSuccessResponse(
            successMessage: 'Cita reservada exitosamente.',
            responseData: new AppointmentResource($newlyCreatedAppointment),
            httpStatusCode: 201
        );
    }

    public function cancelExistingAppointment(Request $request, int $appointmentIdentifier): JsonResponse
    {
        $authenticatedUser = $request->user();

        $cancelledPatientAppointment = $this->appointmentManagementService->cancelPatientAppointment(
            authenticatedUser: $authenticatedUser,
            appointmentIdentifier: $appointmentIdentifier
        );

        return $this->buildSuccessResponse(
            successMessage: 'Cita cancelada correctamente.',
            responseData: new AppointmentResource($cancelledPatientAppointment)
        );
    }

    private function calculateItemsPerPage(Request $request): int
    {
        $requestedItemsPerPage = $request->input(
            'per_page', 
            self::DEFAULT_APPOINTMENTS_PER_PAGE
        );
        
        return min(
            max($requestedItemsPerPage, self::MINIMUM_APPOINTMENTS_PER_PAGE),
            self::MAXIMUM_APPOINTMENTS_PER_PAGE
        );
    }

    private function buildSuccessResponse(
        string $successMessage, 
        $responseData, 
        int $httpStatusCode = 200
    ): JsonResponse {
        return response()->json([
            'message' => $successMessage,
            'data' => $responseData,
        ], $httpStatusCode);
    }
}
