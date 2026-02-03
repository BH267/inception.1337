#!/bin/bash
set -e

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
while ! mysqladmin ping -h mariadb -u wpuser -p$(cat /run/secrets/db_password) --silent; do
    sleep 2
done
echo "MariaDB is ready!"

if ! wp core is-installed --allow-root --path=/var/www/html 2>/dev/null; then
    echo "WordPress not installed. Installing..."

	if [ ! -f "/var/www/html/wp-config.php" ]; then
	wp config create \
	    --dbname=$MYSQL_DATABASE \
	    --dbuser=$MYSQL_USER \
	    --dbpass=$(cat $MYSQL_PASSWORD_FILE) \
	    --dbhost=$MYSQL_HOST \
	    --allow-root \
	    --path=/var/www/html
	fi

	wp core install \
	  --url="https://$HOST_IP" \
	  --title="inception" \
	  --admin_user="$WP_ADMIN_USER" \
	  --admin_password="$(cat $WP_ADMIN_PASSWORD_FILE)" \
	  --admin_email="$WP_ADMIN_EMAIL" \
	  --skip-email \
	  --allow-root

	 echo "WordPress installed successfully."
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
fi

echo "Starting PHP-FPM..."
exec php-fpm8.2 --nodaemonize
