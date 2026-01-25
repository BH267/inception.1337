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
