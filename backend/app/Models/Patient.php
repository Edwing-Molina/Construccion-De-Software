<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;

class Patient extends Model
{
    use HasFactory, SoftDeletes;
    protected $fillable = [
        'user_id',
        'birth',
        'blood_type',
        'emergency_contact_name',
        'emergency_contact_phone',
        'nss_number'
    ];

    protected $hidden = [
        'nss_number',
        'deleted_at',
    ];

    protected $casts = [
        'birth' => 'date',
    ];

    public function user() {
        return $this->belongsTo(User::class);
    }
}

