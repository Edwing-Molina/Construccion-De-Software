<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin \App\Models\Specialty
 */
final class SpecialtyResource extends JsonResource
{
    /**
     * Transform the specialty resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'doctors_count' => $this->when(
                $this->relationLoaded('doctors'),
                fn() => $this->doctors->count()
            ),
        ];
    }
}
