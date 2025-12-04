<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Specialty;
use Illuminate\Http\Request;

class SpecialtyController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $specialty = Specialty::all();

        return response()->json([
            'data' => $specialty
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(Specialty $specialty)
    {
        return response()->json($specialty);
    }


    public function search(Request $request)
    {
        $request->validate([
            'search' => 'required|string',
        ]);

        $specialty = Specialty::where('name', 'like', '%' . $request->search . '%')->get();

        if ($specialty->isEmpty()) {
            return response()->json(['message' => 'No se encontraron especialidades'], 404);
        }

        return response()->json(['data' => $specialty]);
    }
}
