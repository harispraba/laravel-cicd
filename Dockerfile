# Use an official PHP runtime as a parent image
FROM php:8.3.8-fpm-alpine
ENV COMPOSER_ALLOW_SUPERUSER=1

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apk update
RUN apk add --no-cache \
    bash \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    libxpm-dev \
    libvpx-dev \
    libzip-dev \
    icu-dev \
    zlib-dev \
    busybox-extras \
    nodejs \
    yarn

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install PHP extensions
RUN docker-php-ext-configure gd --with-jpeg --with-webp --with-xpm
RUN docker-php-ext-configure intl
RUN docker-php-ext-install gd pdo_mysql zip intl

# Copy application source code
COPY composer.json composer.lock ./

# Install application dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-req=ext-zip
RUN yarn install

# Copy application source code
COPY . .

# Copy the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Change ownership of our applications
RUN chown -R www-data:www-data /var/www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["docker-entrypoint.sh"]
