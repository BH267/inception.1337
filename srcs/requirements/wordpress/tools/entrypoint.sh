#!/bin/bash
set -e

chown -R www-data:www-data /var/www/html 2>/dev/null || true
find /var/www/html -type d -exec chmod 755 {} + 2>/dev/null || true
find /var/www/html -type f -exec chmod 644 {} + 2>/dev/null || true
chmod -R 777 /var/www/html/wp-content 2>/dev/null || true


echo "Waiting for MariaDB..."
while ! mysqladmin ping -h mariadb -u wpuser -p$(cat /run/secrets/db_password) --silent; do
    sleep 2
done
echo "MariaDB is ready!"

WP_URL="https://${HOST_IP:-localhost}"

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
	  --url="$WP_URL" \
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

if wp core is-installed --allow-root --path=/var/www/html 2>/dev/null; then
       current_siteurl=$(wp option get siteurl --allow-root --path=/var/www/html 2>/dev/null || true)
       current_home=$(wp option get home --allow-root --path=/var/www/html 2>/dev/null || true)
       if [ "$current_siteurl" != "$WP_URL" ] || [ "$current_home" != "$WP_URL" ]; then
               wp option update siteurl "$WP_URL" --allow-root --path=/var/www/html >/dev/null 2>&1 || true
               wp option update home "$WP_URL" --allow-root --path=/var/www/html >/dev/null 2>&1 || true
       fi
fi

chmod -R 777 /var/www/html/

echo "Starting PHP-FPM..."
exec php-fpm8.2 --nodaemonize
