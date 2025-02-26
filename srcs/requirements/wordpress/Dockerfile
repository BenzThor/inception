ARG ALPINE_VERSION=3.20
FROM alpine:${ALPINE_VERSION}
ARG PHP_VERSION

# Install PHP and necessary extensions along with MariaDB client
RUN apk add --no-cache --update php${PHP_VERSION} curl php${PHP_VERSION}-mysqli php${PHP_VERSION}-fpm php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-json php${PHP_VERSION}-curl php${PHP_VERSION}-phar  php${PHP_VERSION}-tokenizer mariadb-client && \
	# Download the latest WordPress tarball
    curl -O https://wordpress.org/latest.tar.gz && \
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	# Create MySQL user and group (if not already created)
	getent group www-data || addgroup -S www-data && \
    getent passwd www-data || adduser -S -G www-data www-data && \
    # Extract the WordPress tarball
    tar -xvzf latest.tar.gz && \
    # Copy the extracted WordPress files to the web root directory
	mkdir -p /var/www/html/ &&\
    cp -R wordpress/* /var/www/html/ && \
    # Clean up: remove the extracted WordPress folder and the tarball
    rm -rf wordpress latest.tar.gz && \
	# change ownership of /var/www
	chown -R www-data:www-data /var/www/ && \
	# Make the WP-CLI PHAR file executable
    chmod +x wp-cli.phar && \
    # Move the WP-CLI PHAR file to a directory in the system PATH to allow global access (as wp)
    mv wp-cli.phar /usr/local/bin/wp && \
	ls /usr/local/bin/wp && \
	#create a symbolic link to be able to execute php-fpmMajorMiniroVersion
	ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/bin/php-fpm

# Copy custom PHP-FPM configuration file to the appropriate PHP version folder
COPY ./conf/php-fpm.conf /etc/php${PHP_VERSION}/
# Copy the custom 'www.conf' configuration file to the php-fpm.d directory for the correct PHP version
COPY ./conf/www.conf /etc/php${PHP_VERSION}/php-fpm.d/
# Copy the wp-init.sh script to the wp-entrypoint.d directory
COPY ./tools/wp-init.sh /wp-entrypoint.d/

WORKDIR /var/www/html/

# Make the wp-init.sh script executable by adding execute permissions
RUN chmod +x /wp-entrypoint.d/wp-init.sh 

EXPOSE 9000

ENTRYPOINT ["sh", "/wp-entrypoint.d/wp-init.sh"]
