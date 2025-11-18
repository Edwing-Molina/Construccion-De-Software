<?php

use App\Http\Controllers\Api\ProfileController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\SpecialtyController;

Route::middleware('auth:sanctum')->group(function () {
    
    Route::prefix('specialties')->group(function () {
        Route::get('/', [SpecialtyController::class, 'index']);
        Route::get('/search', [SpecialtyController::class, 'search']); // Must be before {specialty}
        Route::get('/{specialty}', [SpecialtyController::class, 'show']);
    });
    
    // Profile Routes
    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'show']);
        Route::put('/', [ProfileController::class, 'update']);
    });
    
    Route::get('/users/{userId}/profile', [ProfileController::class, 'showPublicProfile']);
    
});
