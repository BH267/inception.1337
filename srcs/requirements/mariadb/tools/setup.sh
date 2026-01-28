#!/bin/bash
set -e

export DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
export DB_PASSWORD=$(cat /run/secrets/db_password)
export WP_ADMIN_USER=$(cat /run/secrets/wp_admin_user)

mkdir -p /var/lib/mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

INIT_MARKER="/var/lib/mysql/.initialized"

if [ ! -f "$INIT_MARKER" ]; then
    echo "First run: Initializing MariaDB..."
    
    echo "Cleaning /var/lib/mysql completely..."
    rm -rf /var/lib/mysql/*
    
    echo "Running mysql_install_db..."
    if ! gosu mysql mysql_install_db --datadir=/var/lib/mysql --skip-test-db; then
        echo "ERROR: mysql_install_db failed!"
        exit 1
    fi
    
    echo "Starting MariaDB in bootstrap mode..."
    gosu mysql mysqld --datadir=/var/lib/mysql --skip-networking=0 --skip-grant-tables &
    MYSQL_PID=$!
    
    for i in {30..0}; do
        if gosu mysql mysqladmin ping -h localhost --silent 2>/dev/null; then
            break
        fi
        echo "Waiting for MariaDB to start... ($i)"
        sleep 1
    done
    
    if [ "$i" = 0 ]; then
        echo "ERROR: MariaDB failed to start!"
        kill $MYSQL_PID 2>/dev/null || true
        exit 1
    fi
    
    echo "Creating database and users..."
    
    gosu mysql mysql <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
CREATE USER IF NOT EXISTS '${WP_ADMIN_USER}'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${WP_ADMIN_USER}'@'%' WITH GRANT OPTION;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
FLUSH PRIVILEGES;
EOF

    if [ $? -eq 0 ]; then
        echo "Database initialization successful!"
        touch "$INIT_MARKER"
    else
        echo "ERROR: Database initialization failed!"
        kill $MYSQL_PID 2>/dev/null || true
        exit 1
    fi
    
    echo "Stopping bootstrap MariaDB instance..."
    kill $MYSQL_PID
    wait $MYSQL_PID 2>/dev/null || true
    
    echo "Initialization complete!"
else
    echo "Database already initialized (marker found)"
fi

echo "Starting MariaDB in foreground..."
exec gosu mysql mysqld --datadir=/var/lib/mysql --console --bind-address=0.0.0.0
