<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

final class TestApiUpdate extends Command
{

    protected $signature = 'test:api-update';
    protected $description = 'Send a test update request to the /api/me endpoint';

    private const ENDPOINT_ME_UPDATE = '/api/me';
    private const BASE_URL_LOCAL = 'http://localhost:8000';
    private const PERSONAL_ACCESS_TOKEN = '2|RyqoGuMLWcRabxESklO3p19zoLZWUokq7tIFJIv7e2fb04c0';


    public function handle(): int
    {
        $requestPayload = $this->makeRequestPayload();

        $this->showRequestPreview($requestPayload);

        try {
            $apiResponse = $this->sendUpdateRequest($requestPayload);

            $this->showResponseSummary($apiResponse);

            return Command::SUCCESS;

        } catch (\Throwable $e) {
            $this->error("Unexpected error: {$e->getMessage()}");
            return Command::FAILURE;
        }
    }

    private function makeRequestPayload(): array
    {
        return [
            'name' => 'Test User Doctor',
            'phone' => '9999999998',

            'doctor' => [
                'description' => 'Soy un doctor actualizado',
                'clinics' => [
                    [
                        'clinic_id' => 1,
                        'office_number' => '88',
                    ],
                ],
            ],

            'specialty_ids' => [1],
        ];
    }

    private function sendUpdateRequest(array $requestPayload)
    {
        return Http::withHeaders([
            'Authorization' => 'Bearer ' . self::PERSONAL_ACCESS_TOKEN,
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
        ])->put($this->resolveEndpointUrl(), $requestPayload);
    }

    private function resolveEndpointUrl(): string
    {
        return rtrim(self::BASE_URL_LOCAL, '/') . self::ENDPOINT_ME_UPDATE;
    }

    private function showRequestPreview(array $requestPayload): void
    {
        $this->info("Sending request to: " . $this->resolveEndpointUrl());
        $this->line("Payload:\n" . json_encode($requestPayload, JSON_PRETTY_PRINT));
    }

    private function showResponseSummary($apiResponse): void
    {
        $this->info("Response Status: " . $apiResponse->status());
        $this->line("Response Body:\n" . $apiResponse->body());
    }
}
