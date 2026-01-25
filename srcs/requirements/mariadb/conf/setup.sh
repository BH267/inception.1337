#!/bin/bash
set -e

export DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
export DB_PASSWORD=$(cat /run/secrets/db_password)
export WP_ADMIN_USER=$(cat /run/secrets/wp_admin_user)

cat > /tmp/init-secure.sql <<EOF
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
CREATE USER IF NOT EXISTS '${WP_ADMIN_USER}'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${WP_ADMIN_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

rm -f /var/run/mysqld/mysqld.pid
rm -f /var/lib/mysql/*.pid

echo "Starting MariaDB..."
mysqld_safe --datadir=/var/lib/mysql --skip-networking=0 &

until mysqladmin ping -h localhost --silent; do
    sleep 1
done

echo "Initializing database..."
mysql -u root < /tmp/init-secure.sql

echo "MariaDB ready. Switching to foreground..."
exec mysqld --datadir=/var/lib/mysql --console
