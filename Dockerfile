FROM php:8.1-fpm


COPY ./php/local.ini /usr/local/etc/php/conf.d/local.ini
COPY  ./php/www.conf /usr/local/etc/php-fpm.d/www.conf

# Set working directory
WORKDIR /var/www/html


# Install dependencies
RUN curl -s https://deb.nodesource.com/setup_16.x | sh

RUN apt-get update && apt-get install -y \
    build-essential apt-utils \
    libpng-dev libjpeg62-turbo-dev libwebp-dev libfreetype6-dev \
    jpegoptim optipng pngquant gifsicle \
    libicu-dev \
    locales \
    vim \
    nano \
    zip \ 
    unzip \
    libzip-dev \
    git \
    nodejs \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql zip exif pcntl fileinfo
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install gd
RUN docker-php-ext-configure intl 
RUN docker-php-ext-install intl

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www
RUN chown -R www:www /var/www/html
RUN chmod -R 755 /var/www/html
USER www
WORKDIR /var/www/html
