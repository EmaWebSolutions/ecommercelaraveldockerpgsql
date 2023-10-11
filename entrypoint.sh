#!/bin/bash

# Check if a flag file exists to determine if migrations and seeders have been run
if [ ! -f /var/www/html/migrations_and_seeders_completed.flag ]; then
    # Print out the values of environment variables for debugging
    echo "DB_HOST: $DB_HOST"
    echo "DB_USERNAME: $DB_USERNAME"
    echo "DB_DATABASE: $DB_DATABASE"

    # Function to check if PostgreSQL is available
    pg_is_available() {
        pg_isready -h $DB_HOST -U $DB_USERNAME -d $DB_DATABASE
        return $?
    }

    # Wait for PostgreSQL to become available
    until pg_is_available; do
        >&2 echo "PostgreSQL is unavailable - sleeping"
        sleep 1
    done

    # Print a message when PostgreSQL is available
    echo "PostgreSQL is available, continuing..."

    # Run Laravel migrations and seeders
    php artisan migrate:fresh --force
    php artisan db:seed --force

    # Create a flag file in the Laravel root directory to indicate that migrations and seeders have been completed
    touch /var/www/html/migrations_and_seeders_completed.flag
fi

# Start PHP-FPM
exec php-fpm
