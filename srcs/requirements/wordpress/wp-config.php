<?php
$db_password = file_get_contents('/run/secrets/db_password');
$wp_admin_user = trim(file_get_contents('/run/secrets/wp_admin_user'));

// Database settings
define('DB_NAME', 'wordpress');
define('DB_USER', 'wpuser');
define('DB_PASSWORD', $db_password);
define('DB_HOST', 'mariadb');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
define('WP_DEBUG', true);

// redis 
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
define('WP_REDIS_TIMEOUT', 1);
define('WP_REDIS_READ_TIMEOUT', 1);
define('WP_REDIS_DATABASE', 0);
define('WP_CACHE', true);

# Install and activate Redis Object Cache plugin
if [ ! -d /var/www/wordpress/wp-content/plugins/redis-cache ]; then
    echo "Installing Redis Object Cache plugin..."
    wp plugin install redis-cache --activate --allow-root --path=/var/www/wordpress > /dev/null 2>&1
    echo "Redis plugin installed!"
fi

# Enable Redis object cache
if ! wp redis status --allow-root --path=/var/www/wordpress 2>/dev/null | grep -q "Connected"; then
    echo "Enabling Redis cache..."
    wp redis enable --allow-root --path=/var/www/wordpress 2>/dev/null || true
    echo "Redis cache enabled!"
fi

// Security keys
define('AUTH_KEY',         'hassan13dev');
define('SECURE_AUTH_KEY',  'hassan13dev');
define('LOGGED_IN_KEY',    'hassan13dev');
define('NONCE_KEY',        'hassan13dev');
define('AUTH_SALT',        'hassan13dev');
define('SECURE_AUTH_SALT', 'hassan13dev');
define('LOGGED_IN_SALT',   'hassan13dev');
define('NONCE_SALT',       'hassan13dev');

$table_prefix = 'wp_';

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

// Load WordPress
require_once ABSPATH . 'wp-settings.php';
?>
