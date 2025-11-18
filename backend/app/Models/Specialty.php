<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Builder;

final class Specialty extends Model
{
    use HasFactory;

    protected $table = 'specialties';
    
    public $timestamps = false;
    
    protected $fillable = ['name'];


    public function doctors(): BelongsToMany
    {
        return $this->belongsToMany(Doctor::class, 'doctor_specialty');
    }


    public function scopeFilterByName(Builder $query, ?string $searchTerm): Builder
    {
        if (empty($searchTerm)) {
            return $query;
        }

        return $query->where('name', 'like', "%{$searchTerm}%");
    }

    
    public function scopeOrderedByName(Builder $query): Builder
    {
        return $query->orderBy('name', 'asc');
    }
}
