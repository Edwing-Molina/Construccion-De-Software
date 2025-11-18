<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Profile\UpdateProfileRequest;
use App\Http\Resources\UserProfileResource;
use App\Services\ProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class ProfileController extends Controller
{
    public function __construct(
        private readonly ProfileService $profileService
    ) {}

    public function show(Request $request): JsonResponse
    {
        $authenticatedUser = $request->user();
        
        return $this->successResponse(
            message: 'Perfil recuperado exitosamente.',
            data: new UserProfileResource($authenticatedUser)
        );
    }

    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $authenticatedUser = $request->user();
        
        $updatedUser = $this->profileService->updateUserProfile(
            user: $authenticatedUser,
            validatedData: $request->validated()
        );

        return $this->successResponse(
            message: 'Perfil actualizado exitosamente.',
            data: new UserProfileResource($updatedUser)
        );
    }

    public function showPublicProfile(int $userId): JsonResponse
    {
        $requestedUser = $this->profileService->getUserById($userId);

        return $this->successResponse(
            message: 'Perfil público recuperado exitosamente.',
            data: new UserProfileResource($requestedUser, showSensitiveData: false)
        );
    }

    private function successResponse(string $message, $data): JsonResponse
    {
        return response()->json([
            'message' => $message,
            'data' => $data,
        ]);
    }
}
