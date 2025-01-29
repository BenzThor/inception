#!/bin/sh
set -e

SQL_FILE="/docker-entrypoint-initdb.d/init-db.sh"

# not really necessary
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

# this is necessary
# Initialize MariaDB if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database"
    mariadb-install-db --no-defaults --datadir=/var/lib/mysql > /dev/null
    chown -R mysql:mysql /var/lib/mysql  # Ensure ownership after initialization
    if [ -f "$SQL_FILE" ]; then
        /bin/sh $SQL_FILE
    else
        echo "No SQL initialization file found at $SQL_FILE"
    fi
fi

# Start MariaDB in the foreground to keep the container running
exec /usr/bin/mysqld --user=mysql --console
