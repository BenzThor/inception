#!/bin/sh

# Define the SQL file path
SQL_FILE="/docker-entrypoint-initdb.d/init-db.sql"

# Generate SQL file with environment variables
cat <<EOF > $SQL_FILE
USE mysql;
FLUSH PRIVILEGES;

DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';

CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PW';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

FLUSH PRIVILEGES;
EOF

# Ensure correct permissions
chmod 755 $SQL_FILE

# Execute the SQL file to set up the database and users
echo "Executing $SQL_FILE to initialize MariaDB..."
mysqld --user=mysql --bootstrap < $SQL_FILE
