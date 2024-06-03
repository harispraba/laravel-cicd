# Use an official PHP runtime as a parent image
FROM php:8.4-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    supervisor \
    && docker-php-ext-install pdo_mysql

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application source code
COPY . .

# Install application dependencies
RUN composer install --no-dev --no-scripts --no-interaction

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["docker-entrypoint.sh"]
