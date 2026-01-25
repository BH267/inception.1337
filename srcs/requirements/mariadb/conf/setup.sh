#!/bin/bash
set -e

export DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
export DB_PASSWORD=$(cat /run/secrets/db_password)
export WP_ADMIN_USER=$(cat /run/secrets/wp_admin_user)

DEBIAN_PASS=$(grep -A 1 "password" /etc/mysql/debian.cnf | tail -n 1 | tr -d ' ')

cat > /tmp/init-secure.sql <<EOF
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
CREATE USER IF NOT EXISTS '${WP_ADMIN_USER}'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${WP_ADMIN_USER}'@'%' WITH GRANT OPTION;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

mkdir -p /var/lib/mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
chmod 755 /var/lib/mysql

rm -f /var/run/mysqld/mysqld.pid
rm -f /var/lib/mysql/*.pid

echo "Starting MariaDB..."
gosu mysql mysqld --datadir=/var/lib/mysql --skip-networking=0 &

until mysqladmin ping -h localhost --silent; do
    sleep 1
done

echo "Initializing database..."
mysql --defaults-file=/etc/mysql/debian.cnf < /tmp/init-secure.sql

echo "MariaDB ready. Switching to foreground..."
kill %1
wait %1 2>/dev/null || true
exec gosu mysql mysqld --datadir=/var/lib/mysql --console
