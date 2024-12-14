# Get the base image (latest version is alpine:3.21)
FROM alpine:3.20

# Copy nginx.conf file into the container
COPY ./conf/nginx.conf /etc/nginx/. \
	# Copy the index.html file to the container
	./conf/index.html /var/www/html/ \
	# Copy the certificate generation script into the container
	./conf/generate-cert.sh /usr/local/bin/

# Install Nginx and OpenSSL
RUN	apk add --no-cache --update openssl nginx ca-certificates && \
   # Create 'www-data' group if it doesn't exist
    getent group www-data || addgroup -S www-data && \
    # Create a new user 'www-data' and add it to the 'www-data' group, without a home directory
    adduser -S -G www-data www-data && \
	# # Make the script executable
	chmod +x /usr/local/bin/generate-cert.sh && \
	# Run the certificate generation script
	/usr/local/bin/generate-cert.sh

USER www-data

# Expose the port
EXPOSE 443

# Set the default command to run Nginx in the foreground, preventing the container from exiting immediately.
CMD ["nginx", "-g", "daemon off;"]
