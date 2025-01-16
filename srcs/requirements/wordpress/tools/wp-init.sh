#!/bin/sh

which wp

if [ ! -f /var/www/html/wp-config.php ]; then
	wp core download --path=/var/www/html
	wp config create --dbname=$DB_NAME_WP --dbuser=$DB_USER_WP --dbpass=$DB_PASSWORD_WP --dbhost=$DB_HOST_WP --path=/var/www/html
	wp core install --url=$URL_WP --title=$TITLE_WP --admin_user=$ADMIN_USER_WP --admin_password=$ADMIN_PAASSWORD_WP --admin_email=$ADMIN_EMAIL_WP --path=/var/www/html
	wp theme install oceanwp --activate --path=/var/www/html
fi

wp plugin update --all

exec php-fpm --nodaemonize
