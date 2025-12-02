<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use App\Enums\DayOfWeek;
use App\Enums\AppointmentStatus;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('doctor_work_patterns', function (Blueprint $table) {
            $table->id();
            $table->foreignId('doctor_id')->constrained('doctors');
            $table->foreignId('clinic_id')->constrained('clinics');
            $table->enum('day_of_week', DayOfWeek::toArray());
            $table->time('start_time_pattern');
            $table->time('end_time_pattern');
            $table->integer('slot_duration_minutes');
            $table->boolean('is_active');
            $table->date('start_date_effective')->nullable();
            $table->date('end_date_effective')->nullable();
            $table->timestamps();
        });

        Schema::create('available_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('doctor_id')->constrained('doctors');
            $table->foreignId('clinic_id')->constrained('clinics');
            $table->date('date');
            $table->time('start_time');
            $table->time('end_time');
            $table->boolean('available')->default(true);
            $table->softDeletes();
            $table->timestamps();

            $table->unique(['doctor_id', 'clinic_id', 'date', 'start_time']);
        });

        Schema::create('appointments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('patient_id')->constrained('patients');
            $table->foreignId('available_schedule_id')->constrained('available_schedules');
            $table->enum('status',AppointmentStatus::toArray())->default(AppointmentStatus::Pendiente->value);
            $table->softDeletes();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('doctor_work_patterns');
        Schema::dropIfExists('available_schedules');
        Schema::dropIfExists('appointments');
    }
};
