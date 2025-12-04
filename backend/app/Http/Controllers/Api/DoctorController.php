<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Models\Doctor;
use Illuminate\Routing\Controller;

class DoctorController extends Controller
{

    public function index(Request $request)
    {
         $filters = $request->only(['id', 'search', 'specialty_id', 'clinic_id']);
        $perPage = $request->input('per_page', 10);
        $doctors = Doctor::filter($filters, $perPage);

        $doctors->getCollection()->transform(function ($doctor) {
            $doctor->makeHidden(['license_number', 'deleted_at', 'created_at', 'updated_at']);
            return $doctor;
        });

        return response()->json($doctors);
    }

}
