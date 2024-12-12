#!/bin/bash
set -e

# Ensure the MySQL user exists and is set up correctly
if ! id -u mysql >/dev/null 2>&1; then
    echo "Creating MySQL user and group"
    addgroup -S mysql
    adduser -S -G mysql mysql
fi

# Ensure the MariaDB data directory exists and has the correct ownership
if [ ! -d "/var/lib/mysql" ]; then
    echo "Creating MariaDB data directory"
    mkdir -p /var/lib/mysql
    chown -R mysql:mysql /var/lib/mysql
fi

# Ensure the MySQL socket directory exists and has the correct ownership
if [ ! -d "/run/mysqld" ]; then
    echo "Creating directory for MySQL socket"
    mkdir -p /run/mysqld
    chown mysql:mysql /run/mysqld
fi

# Ensure the ownership of the MariaDB data directory is mysql:mysql
if [ "$(stat -c '%U' /var/lib/mysql)" != "mysql" ] || [ "$(stat -c '%G' /var/lib/mysql)" != "mysql" ]; then
    echo "Setting correct ownership for the MariaDB data directory"
    chown -R mysql:mysql /var/lib/mysql
fi

# Initialize MariaDB if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database"
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    chown -R mysql:mysql /var/lib/mysql  # Ensure ownership after initialization
fi


echo "Starting MariaDB server in background"
# Start the MariaDB server in the background
mysqld --user=mysql --datadir=/var/lib/mysql &

echo "Waiting for MariaDB to be fully ready..."
until mysqladmin ping -h localhost --silent; do
    sleep 1
done

echo "MariaDB is up and running."

# Run any custom initialization scripts in /docker-entrypoint-initdb.d
echo "Running initialization scripts from /docker-entrypoint-initdb.d"
for f in /docker-entrypoint-initdb.d/*; do
    case "$f" in
        *.sh)  echo "Running $f"; . "$f" ;;
        *.sql) echo "Running $f"; mysql -u root -p"$MYSQL_ROOT_PASSWORD" < "$f";;
        *)      echo "Ignoring $f" ;;
    esac
done

# Start MariaDB in the foreground to keep the container running
wait $(jobs -p)  # Wait for the MariaDB process (background job) to finish