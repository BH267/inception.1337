<?php
$db_password = trim(file_get_contents(getenv('MYSQL_PASSWORD_FILE')));
$wp_security_key = trim(file_get_contents(getenv('WP_SECURITY_KEYS_FILE')));

// Database settings
define('DB_NAME', getenv('MYSQL_DATABASE'));
define('DB_USER', getenv('MYSQL_USER'));
define('DB_PASSWORD', $db_password);
define('DB_HOST', getenv('MYSQL_HOST'));
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

// Security keys
define('AUTH_KEY',         $wp_security_key);
define('SECURE_AUTH_KEY',  $wp_security_key);
define('LOGGED_IN_KEY',    $wp_security_key);
define('NONCE_KEY',        $wp_security_key);
define('AUTH_SALT',        $wp_security_key);
define('SECURE_AUTH_SALT', $wp_security_key);
define('LOGGED_IN_SALT',   $wp_security_key);
define('NONCE_SALT',       $wp_security_key);

define('FTP_USER', getenv('MYSQL_USER'));
define('FTP_PASS', $db_password);
define('FTP_HOST',  getenv('HOST_IP'));//'10.14.57.3');//'localhost');

$table_prefix = 'wp_';

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
?>
