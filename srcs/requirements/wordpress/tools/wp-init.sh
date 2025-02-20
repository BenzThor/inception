#!/bin/sh

wait_for_maria_db() {
	echo "waiting for MariaDB to be healthy..."
	while ! mysqladmin ping -h"$DB_HOST_WP" -u"$DB_USER_WP" -p"$DB_PASSWORD_WP" --silent; do
		echo "MariaDB is not ready yet. Retrying in 5 seconds..."
        sleep 5
	done
	echo "MariaDB is healthy! Proceeding with WordPress initialization."
}

if [ ! -f /var/www/html/wp-config.php ]; then
	# wp core download --path=/var/www/html/
	wait_for_maria_db
	wp config create --dbname="$DB_NAME_WP" --dbuser="$DB_USER_WP" --dbpass="$DB_PASSWORD_WP" --dbhost="$DB_HOST_WP"
	wp core install --url="$URL_WP" --title="$TITLE_WP" --admin_user="$ADMIN_USER_WP" --admin_password="$ADMIN_PASSWORD_WP" --admin_email="$ADMIN_EMAIL_WP"
	wp theme install oceanwp --activate
fi

# wp plugin update --all

exec php-fpm --nodaemonize
