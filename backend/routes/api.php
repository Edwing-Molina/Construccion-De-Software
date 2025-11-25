<?php

use App\Http\Controllers\Api\ProfileController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\SpecialtyController;
use App\Http\Controllers\Api\PatientAppointmentController;

Route::middleware('auth:sanctum')->group(function () {
    
    Route::prefix('specialties')->group(function () {
        Route::get('/', [SpecialtyController::class, 'index']);
        Route::get('/search', [SpecialtyController::class, 'search']);
        Route::get('/{specialty}', [SpecialtyController::class, 'show']);
    });
    
    Route::prefix('profile')->group(function () {
        Route::get('/', [ProfileController::class, 'show']);
        Route::put('/', [ProfileController::class, 'update']);
    });
    
    Route::get('/users/{userId}/profile', [ProfileController::class, 'showPublicProfile']);
    
    Route::prefix('appointments')->name('patient.appointments.')->group(function () {
        Route::get('/', [PatientAppointmentController::class, 'listPatientAppointments'])
            ->name('list');
            
        Route::post('/', [PatientAppointmentController::class, 'bookNewAppointment'])
            ->name('book');
            
        Route::patch('/{appointmentIdentifier}/cancel', [PatientAppointmentController::class, 'cancelExistingAppointment'])
            ->name('cancel');
    });

});
