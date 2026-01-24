#!/bin/bash
set -e

CERT_DIR="/etc/nginx/ssl"
CERT_FILE="$CERT_DIR/fullchain.pem"
KEY_FILE="$CERT_DIR/privkey.pem"

# Generate self-signed cert if it doesn't exist
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
    echo "Generating self-signed TLS certificate..."
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE" \
        -subj "/C=MA/ST=Souss-Massa/L=Agadir/O=42/CN=habenydi.42.fr"
fi

exec nginx -g "daemon off;"
