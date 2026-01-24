#!/bin/bash
set -e

export DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
export DB_PASSWORD=$(cat /run/secrets/db_password)
export WP_ADMIN_USER=$(cat /run/secrets/wp_admin_user)

cat > /tmp/init-secure.sql <<EOF
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER 'wpuser'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
CREATE USER '${WP_ADMIN_USER}'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${WP_ADMIN_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

mysqld_safe --datadir=/var/lib/mysql &

until mysqladmin ping -h localhost --silent; do
    sleep 1
done

# run secure init
mysql -u root < /tmp/init-secure.sql

# keep logs visible
tail -F /var/log/mysql/error.log &

exec mysqld_safe --datadir=/var/lib/mysql
