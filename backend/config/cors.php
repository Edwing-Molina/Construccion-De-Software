<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your settings for cross-origin resource sharing
    | or "CORS". This determines what cross-origin requests are allowed on
    | your API. The "supports_credentials" option determines whether your API
    | will support cookies on cross-origin requests.
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        'http://localhost:3000',
        'http://localhost:8000',
        'http://localhost:8080',
        'http://localhost:5000',
        'http://localhost:5173', // Vite default port
        'http://localhost:4200',  // Angular default
        'http://127.0.0.1:3000',
        'http://127.0.0.1:8000',
        'http://127.0.0.1:8080',
        'http://127.0.0.1:5173',
        'http://127.0.0.1:4200',
        'http://sistema-citas-medicas.test',
        'http://192.168.1.177:8000',
        'http://192.168.1.254:8000',
        'http://192.168.1.233:8000',
        'http://192.168.1.177',
        'http://192.168.1.254',
        'http://192.168.1.233',
        'http://backend.test',
        // Flutter mobile/web
        'http://localhost',
        'http://127.0.0.1',
    ],

    'allowed_origins_patterns' => [
        '/http:\/\/192\.168\..*/i',  // Allow all 192.168.* origins
        '/http:\/\/localhost.*/i',
        '/http:\/\/127\.0\.0\.1.*/i',
    ],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => true,

];
