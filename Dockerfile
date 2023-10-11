# Use the official PHP 8.2 image as the base image
FROM php:8.2-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    libonig-dev \
    libzip-dev \
    postgresql-client \
    libpq-dev \  
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql mbstring zip exif pdo_pgsql

# Set the working directory in the container
WORKDIR /var/www/html

# Copy the Laravel application files to the container
COPY . .


# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Laravel dependencies, ignoring platform requirements
RUN composer install --ignore-platform-reqs


RUN chown -R www-data:www-data storage
RUN chmod -R 775 storage


# Make the entrypoint.sh script executable within the container
RUN chmod +x ./entrypoint.sh

# Expose port 9000 for PHP-FPM (you can remove this if not needed)
EXPOSE 9000

# Use the custom entrypoint script as the container command
CMD ["./entrypoint.sh"]
