#!/bin/sh

#tells the shell to exit immediately if any command fails (returns a non-zero status)
set -e

# Print all commands as they are executed for debugging purposes
set -x

# Set default values for certificate fields if not already set via environment variables
DOMAIN=${DOMAIN:-tbenz.42.fr}                # Default domain if not set
DAYS=${DAYS:-365}                             # Validity period of the certificate in days
COUNTRY=${COUNTRY:-AT}                   # Country name (ISO 3166-1)
STATE=${STATE:-Vienna}                        # State or province
LOCALITY=${LOCALITY:-19}                      # City or locality
ORGANIZATION=${ORGANIZATION:-42 Vienna}       # Organization name
ORGANIZATIONAL_UNIT=${ORGANIZATIONAL_UNIT:-IT} # Organizational unit (department)
EMAIL=${EMAIL:-bocal@42vienna.com}            # Email address for the certificate

# Create directories for certs if they do not exist
mkdir -p /etc/ssl/private /etc/ssl/certs

# Generate SSL certificate
# Generate the self-signed SSL certificate
# -x509: Generate a self-signed certificate
# -nodes: Do not encrypt the private key
# -days: Specifies the validity period of the certificate
# -newkey ec: Generate a new ECDSA private key
# -pkeyopt ec_paramgen_curve:prime256v1: Use the prime256v1 curve for the ECDSA key
# -keyout: Output file for the private key
# -out: Output file for the certificate
# -subj: Specify subject information for the certificate (e.g., country, state, organization)
openssl req -x509 -nodes -days $DAYS -newkey ec \
  -pkeyopt ec_paramgen_curve:prime256v1 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt \
  -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$DOMAIN/emailAddress=$EMAIL"

# Update CA certificates
update-ca-certificates