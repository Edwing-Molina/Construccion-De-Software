<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;

class Clinic extends Model
{
    use HasFactory, SoftDeletes;
    protected $fillable = [
        'name', 
        'address'
    ];

    public function doctors() { 
        return $this->belongsToMany(Doctor::class, 'doctor_clinic')->withPivot('office_number'); 
    }

}
