<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\SpecialtyController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\DoctorController;
use App\Http\Controllers\Api\DoctorAppointmentController;
use App\Http\Controllers\Api\PatientAppointmentController;
use App\Http\Controllers\Api\AvailableSchedulesController;
use App\Http\Controllers\Api\WorkPatternsController;
use Illuminate\Support\Facades\Log;

require __DIR__.'/auth.php';

Route::middleware('auth:sanctum')->group(function () {

    //funcionan usando solo el usuario autenticado (no reciben id)
    Route::get('/me',[ProfileController::class, 'show']);
    Route::put('/me',[ProfileController::class, 'update']);
    
    Route::get('show/{id}/profile', [ProfileController::class, 'showOtherUser']);

    Route::prefix('specialtys')->group(function () {
        Route::get('/', [SpecialtyController::class, 'index']);
    });

    Route::prefix('doctors')->group(function () {
        Route::get('/', [DoctorController::class, 'index']);
    });

    // Rutas para usuarios con el rol de pacientes
    Route::middleware('role:patient')->group(function() {

        Route::apiResource('patient-appointments', PatientAppointmentController::class);

        
        Route::prefix('patient-available-schedules')->group(function () {

            Route::get('/', [AvailableSchedulesController::class, 'index']);

        });
        
    });

    // Rutas para usuarios con el rol de doctores
    Route::middleware('role:doctor')->group(function () {

        Route::prefix('doctor-appointments')->group(function() {

            Route::get('/', [DoctorAppointmentController::class, 'index']);

            Route::put('/{appointment_id}/complete', [DoctorAppointmentController::class, 'update']);
                
            });
        
        Route::prefix('doctor-available-schedules')->group(function() {

            Route::get('/', [AvailableSchedulesController::class, 'index']);

            Route::post('/generate', [AvailableSchedulesController::class, 'store']);

        });

        Route::apiResource('work-patterns', WorkPatternsController::class);

        });

});