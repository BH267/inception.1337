#!/bin/bash
set -e

export DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
export DB_PASSWORD=$(cat /run/secrets/db_password)
export WP_ADMIN_USER=$(cat /run/secrets/wp_admin_user)

mkdir -p /var/lib/mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

echo "Starting MariaDB..."
gosu mysql mysqld --datadir=/var/lib/mysql --skip-networking=0 &

until gosu mysql mysqladmin ping -h localhost --silent; do
    sleep 1
done

cat > /tmp/init-secure.sql <<EOF
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
CREATE USER IF NOT EXISTS '${WP_ADMIN_USER}'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${WP_ADMIN_USER}'@'%' WITH GRANT OPTION;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

echo "Initializing database..."
gosu mysql mysql --defaults-file=/etc/mysql/debian.cnf < /tmp/init-secure.sql

kill %1
wait %1 2>/dev/null || true

echo "MariaDB initialized. Starting in foreground..."
exec gosu mysql mysqld --datadir=/var/lib/mysql --console
