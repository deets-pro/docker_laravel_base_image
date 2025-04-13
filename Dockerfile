# Build stage
FROM composer:2.6 AS composer

# PHP-FPM stage
FROM php:8.2-fpm

# Copy PHP configuration files
COPY ./php/local.ini /usr/local/etc/php/conf.d/local.ini
COPY ./php/www.conf /usr/local/etc/php-fpm.d/www.conf

# Set working directory
WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libfreetype6-dev \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    libicu-dev \
    locales \
    zip \
    unzip \
    libzip-dev \
    git \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) pdo_mysql zip exif pcntl fileinfo gd intl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -s https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy Composer from composer stage
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Add user for Laravel application
RUN groupadd -g 1000 www \
    && useradd -u 1000 -ms /bin/bash -g www www \
    && chown -R www:www /var/www/html \
    && chmod -R 755 /var/www/html

# Switch to non-root user
USER www

# Set working directory
WORKDIR /var/www/html
