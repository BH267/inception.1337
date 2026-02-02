#!/bin/bash
set -e

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
while ! mysqladmin ping -h mariadb -u wpuser -p$(cat /run/secrets/db_password) --silent; do
    sleep 2
done
echo "MariaDB is ready!"

wp core install \
  --url="https://10.14.57.3/" \
  --title="inception" \
  --admin_user="hassan" \
  --admin_password="password" \
  --admin_email="habenydi@student.1337.ma" \
  --skip-email \
  --allow-root

if [ ! -d "/var/www/html/wp-content/plugins/redis-cache" ]; then
    echo "Installing Redis Object Cache plugin..."
    wp plugin install redis-cache --activate --allow-root --path=/var/www/html
    echo "Redis plugin installed!"
fi

if ! wp redis status --allow-root --path=/var/www/html 2>/dev/null | grep -q "Connected"; then
    echo "Enabling Redis cache..."
    wp redis enable --allow-root --path=/var/www/html 2>/dev/null || true
    echo "Redis cache enabled!"
fi

exec php-fpm8.2 --nodaemonize
