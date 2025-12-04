FROM php:8.3-fpm-alpine

WORKDIR /app

RUN apk add --no-cache \
    curl \
    git \
    libpq-dev \
    zip \
    unzip && \
    docker-php-ext-install \
    pdo \
    pdo_pgsql \
    zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY . .

RUN composer install --no-dev --optimize-autoloader && \
    chmod -R 755 storage bootstrap/cache && \
    php artisan config:cache && \
    php artisan route:cache

EXPOSE 8000

CMD ["sh", "-c", "php artisan migrate --force && php -S 0.0.0.0:8000 -t public"]
