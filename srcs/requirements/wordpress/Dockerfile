FROM alpine:3.20

# Install PHP and necessary extensions along with MariaDB client
RUN apk add --no-cache --update php curl php-mysqli php-fpm php-mbstring php-xml php-json php-curl php-phar mariadb-client && \
    #create a symbolic link to be able to execute php-fpmMajorMiniroVersion
	ln -s /usr/sbin/php-fpm83 /usr/bin/php-fpm && \
	# Download the latest WordPress tarball
    curl -O https://wordpress.org/latest.tar.gz && \
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    # Extract the WordPress tarball
    tar -xvzf latest.tar.gz && \
    # Copy the extracted WordPress files to the web root directory
	mkdir -p /var/www/html/ &&\
    cp -R wordpress/* /var/www/html/ && \
    # Clean up: remove the extracted WordPress folder and the tarball
    rm -rf wordpress latest.tar.gz && \
	# Make the WP-CLI PHAR file executable
    chmod +x wp-cli.phar && \
    # Move the WP-CLI PHAR file to a directory in the system PATH to allow global access (as wp)
    mv wp-cli.phar /usr/local/bin/wp && \
	# Create MySQL user and group (if not already created)
	getent group tbenz || addgroup -S tbenz && \
    getent passwd tbenz || adduser -S -G tbenz tbenz && \
	# Get the version number of php
	PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;") && \
	# and store it
	echo "PHP_VERSION=${PHP_VERSION}" >> /etc/environment

ENV PHP_VERSION=$(PHP_VERSION)

# Copy custom PHP-FPM configuration file to the appropriate PHP version folder
COPY ./conf/php-fpm.conf /etc/php/${PHP_VERSION}/
# Copy the custom 'www.conf' configuration file to the php-fpm.d directory for the correct PHP version
COPY ./conf/www.conf /etc/php/${PHP_VERSION}/php-fpm.d/
# Copy the wp-init.sh script to the wp-entrypoint.d directory
COPY ./tools/wp-init.sh /wp-entrypoint.d/

# Make the wp-init.sh script executable by adding execute permissions
RUN chmod +x /wp-entrypoint.d/wp-init.sh

EXPOSE 9000

ENTRYPOINT ["sh", "/wp-entrypoint.d/wp-init.sh"]