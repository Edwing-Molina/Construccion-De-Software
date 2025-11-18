<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('doctor_clinics', function (Blueprint $table) {
            $table->foreignId('doctor_id')->constrained('doctors');
            $table->foreignId('clinic_id')->constrained('clinics');
            $table->string('office_number')->nullable();
            $table->timestamps();
            $table->primary(['doctor_id', 'clinic_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('doctor_clinics');
    }
};