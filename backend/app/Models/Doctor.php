<?php

declare(strict_types=1);

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;
use App\Models\Clinic;
use Illuminate\Database\Eloquent\SoftDeletes;

class Doctor extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'user_id',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function specialties()
    {
        return $this->belongsToMany(Specialty::class, 'doctor_specialty');
    }

    public function clinics()
    {
        return $this->belongsToMany(Clinic::class, 'doctor_clinics')
                    ->withPivot('office_number');
    }

    public function appointments()
    {
        return $this->hasMany(Appointment::class);
    }

    public function availableSchedules()
    {
        return $this->hasMany(AvailableSchedule::class);
    }

    public function isAvailable(Carbon $requestedDateTime, int $specialtyId): bool
    {
        $hasAvailableSchedule = $this->availableSchedules()
            ->where('date', $requestedDateTime->toDateString())
            ->where('start_time', $requestedDateTime->format('H:i:s'))
            ->where('available', true)
            ->exists();

        if (! $hasAvailableSchedule) {
            return false;
        }

        $existingAppointment = Appointment::whereHas(
            'availableSchedule',
            function ($query) use ($requestedDateTime, $specialtyId) {
                $query->where('doctor_id', $this->id)
                    ->where('date', $requestedDateTime->toDateString())
                    ->where('start_time', $requestedDateTime->format('H:i:s'));
            }
        )
        ->whereIn('status', ['pending', 'confirmed'])
        ->exists();

        if ($existingAppointment) {
            return false;
        }

        return true;
    }

    public function setLicenseNumberAttribute($value): void
    {
        $this->attributes['license_number'] = hash('sha256', $value);
    }

    public static function filter($filters, $perPage = 10)
    {
        $query = self::with(['user', 'specialties', 'clinics']);

        if (isset($filters['id']) && is_numeric($filters['id'])) {
            $query->where('id', '=', $filters['id']);
        }

        if (isset($filters['search'])) {
            $search = $filters['search'];

            $query->whereHas(
                'user',
                function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%");
                }
            );
        }

        if (isset($filters['specialty_id'])) {
            $query->whereHas(
                'specialties',
                function ($q) use ($filters) {
                    $q->where('id', $filters['specialty_id']);
                }
            );
        }

        if (isset($filters['clinic_id'])) {
            $query->whereHas(
                'clinics',
                function ($q) use ($filters) {
                    $q->where('id', $filters['clinic_id']);
                }
            );
        }

        return $query->paginate($perPage);
    }
}
