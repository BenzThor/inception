ARG ALPINE_VERSION

FROM alpine:${ALPINE_VERSION}

# Install MariaDB and necessary tools
RUN apk add --no-cache --update mariadb mariadb-client && \
# Create MySQL user and group (if not already created)
getent group mysql || addgroup -S mysql && \
getent passwd mysql || adduser -S -G mysql mysql && \
# Create the MariaDB data and socket directory and set correct ownership
mkdir -p /var/lib/mysql /run/mysqld && \
chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Copy custom initialization and entrypoint scripts
COPY ./conf/entrypoint.sh /usr/local/bin/
COPY ./tools/init-db.sh /docker-entrypoint-initdb.d/

# Make the scripts executable
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh /usr/local/bin/entrypoint.sh

# Switch to mysql user for running MariaDB
USER mysql

# Expose the default MariaDB port
EXPOSE 3306

# Set the custom entrypoint script
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
