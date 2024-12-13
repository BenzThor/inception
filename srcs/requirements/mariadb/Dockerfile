# Use a lightweight Alpine image as the base
FROM alpine:3.19

# Install MariaDB and necessary tools
RUN apk update && \
    apk add --no-cache mariadb mariadb-client

# Create MySQL user and group (if not already created)
RUN getent group mysql || addgroup -S mysql && \
    getent passwd mysql || adduser -S -G mysql mysql

# Create the MariaDB data and socket directory and set correct ownership
RUN mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Copy custom initialization and entrypoint scripts
COPY ./conf/entrypoint.sh /usr/local/bin/
COPY ./tools/init-db.sh /docker-entrypoint-initdb.d/

# Make the scripts executable
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh /usr/local/bin/entrypoint.sh

# Expose the default MariaDB port
EXPOSE 3306

# Set the custom entrypoint script
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
