# Use a lightweight Alpine image as the base
FROM alpine:3.20

# Copy custom initialization and entrypoint scripts
COPY ./conf/entrypoint.sh /usr/local/bin/ \
	 ./tools/init-db.sh /docker-entrypoint-initdb.d/

# Install MariaDB and necessary tools
RUN apk add --no-cache --update mariadb mariadb-client && \
	# Create MySQL user and group (if not already created)
	getent group mysql || addgroup -S mysql && \
    getent passwd mysql || adduser -S -G mysql mysql && \
	# Create the MariaDB data and socket directory and set correct ownership
	mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld
	# Make the scripts executabl
	chmod +x /docker-entrypoint-initdb.d/init-db.sh /usr/local/bin/entrypoint.sh

# Switch to mysql user for running MariaDB
USER mysql

# Expose the default MariaDB port
EXPOSE 3306

# Set the custom entrypoint script
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
