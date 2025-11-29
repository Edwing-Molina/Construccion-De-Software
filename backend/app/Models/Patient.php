<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Patient extends Model
{

    use SoftDeletes;
    protected $fillable = [
        'user_id',
        'birth',
        'blood_type',
        'emergency_contact_name',
        'emergency_contact_phone',
        'nss_number'
    ];

    public function user() {
        return $this->belongsTo(User::class);
    }

}
