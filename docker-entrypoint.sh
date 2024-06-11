#!/bin/sh

# Function to check if a table exists
check_table_exists() {
    php -r "
    \$connection = new PDO('mysql:host='.\$_SERVER['DB_HOST'].';dbname='.\$_SERVER['DB_DATABASE'], \$_SERVER['DB_USERNAME'], \$_SERVER['DB_PASSWORD']);
    \$result = \$connection->query(\"SHOW TABLES LIKE 'migrations'\")->rowCount();
    exit(\$result ? 0 : 1);
    "
}

# Check if migrations table exists, and if not, run migrations
if check_table_exists; then
    echo "Migrations table exists. Skipping migration."
else
    echo "Migrations table does not exist. Running migrations."
    php artisan migrate --force
    php artisan db:seed --force
fi

# Generate the application key (only if not already set)
if [ -z "$APP_KEY" ]; then
    php artisan key:generate --force
fi

# Start supervisord
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf "$@"
