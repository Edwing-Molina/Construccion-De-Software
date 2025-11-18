<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Models\Doctor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

// ...existing code...

class DoctorController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $filters = $request->only(
            ['id', 'search', 'specialty_id', 'clinic_id']
        );

        $perPage = (int) $request->input('per_page', 10);

        $doctors = Doctor::filter($filters, $perPage);

        $doctors->getCollection()->transform(
            static function (Doctor $doctor) {
                $doctor->makeHidden(
                    [
                        'license_number',
                        'deleted_at',
                        'created_at',
                        'updated_at',
                    ]
                );

                return $doctor;
            }
        );

        return response()->json($doctors);
    }
}