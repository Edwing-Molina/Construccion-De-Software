<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Doctor;
use Illuminate\Pagination\LengthAwarePaginator;

final class DoctorService
{
    /**
     * Search doctors using filters. Supported filters:
     * - specialty_id (int)
     * - clinic_id (int)
     * - search (string) - partial match against user.name
     *
     * Returns a paginated result using Doctor::filter() for query logic.
     *
     * @param array $filters
     * @param int $perPage
     * @return LengthAwarePaginator
     */
    public function search(array $filters = [], int $perPage = 10): LengthAwarePaginator
    {
        // Delegate to the model-level filter which encapsulates query construction.
        return Doctor::filter($filters, $perPage);
    }

    /**
     * Convenience wrapper to search by specialty id only.
     *
     * @param int $specialtyId
     * @param int $perPage
     * @return LengthAwarePaginator
     */
    public function searchBySpecialty(int $specialtyId, int $perPage = 10): LengthAwarePaginator
    {
        return $this->search(['specialty_id' => $specialtyId], $perPage);
    }
}
