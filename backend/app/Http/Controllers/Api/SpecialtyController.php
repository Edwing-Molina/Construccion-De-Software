<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\SpecialtyResource;
use App\Models\Specialty;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class SpecialtyController extends Controller
{
    /**
     * Get all available medical specialties.
     */
    public function index(): JsonResponse
    {
        $allSpecialties = Specialty::orderedByName()->get();

        return $this->successResponse(
            data: SpecialtyResource::collection($allSpecialties)
        );
    }

    /**
     * Get details of a specific specialty.
     */
    public function show(Specialty $specialty): JsonResponse
    {
        return $this->successResponse(
            data: new SpecialtyResource($specialty)
        );
    }

    /**
     * Search specialties by name (case-insensitive).
     */
    public function search(Request $request): JsonResponse
    {
        $validatedData = $request->validate([
            'search' => ['required', 'string', 'min:1', 'max:255'],
        ]);

        $searchTerm = $validatedData['search'];
        $matchingSpecialties = Specialty::filterByName($searchTerm)
            ->orderedByName()
            ->get();

        if ($matchingSpecialties->isEmpty()) {
            return $this->notFoundResponse(
                message: 'No se encontraron especialidades con ese criterio.'
            );
        }

        return $this->successResponse(
            data: SpecialtyResource::collection($matchingSpecialties)
        );
    }

    /**
     * Return successful response with data.
     */
    private function successResponse($data): JsonResponse
    {
        return response()->json([
            'data' => $data,
        ]);
    }

    /**
     * Return not found response with empty data.
     */
    private function notFoundResponse(string $message): JsonResponse
    {
        return response()->json([
            'message' => $message,
            'data' => [],
        ], 404);
    }
}
