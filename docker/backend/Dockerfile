FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libicu-dev libxml2-dev libonig-dev libpq-dev \
 && docker-php-ext-install pdo_mysql zip intl bcmath opcache

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
EXPOSE 9000
