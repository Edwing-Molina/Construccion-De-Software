<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

final class AvailableSchedule extends Model
{
    use HasFactory;

    protected $fillable = [
        'doctor_id',
        'date',
        'start_time',
        'end_time',
        'available',
    ];

    protected $casts = [
        'date' => 'date',
        'available' => 'boolean',
    ];


    public function doctor(): BelongsTo
    {
        return $this->belongsTo(Doctor::class);
    }

    public function appointments(): HasMany
    {
        return $this->hasMany(Appointment::class);
    }


    public function markAsAvailable(): bool
    {
        return $this->update(['available' => true]);
    }

    public function markAsUnavailable(): bool
    {
        return $this->update(['available' => false]);
    }

    public function isAvailable(): bool
    {
        return $this->available === true;
    }

    public function isInFuture(): bool
    {
        $scheduleDateTime = \Carbon\Carbon::parse($this->date . ' ' . $this->start_time);
        return $scheduleDateTime->isFuture();
    }
}
