#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <domain> [--stop-after-configfile-check] [--interactive] [--upgrade] [--beta] [--backup-path path] [--backup]
              [--silent-backup] [--no-mail] [--restore path] [--skip-checks]"
    exit 1
fi

# Save the first argument
arg1="$1"

# If the second argument is provided, save it
if [ $# -ge 2 ]; then
    arg2="$2"
fi

# Execute the Python script if arg2 is provided
if [ -n "$arg2" ]; then
    ./run.py "$arg2" "$arg1" &
    wait  # Wait for the Python script to finish
    echo 'Modoboa installed successfully'
fi
# Add HDNS Nameserver

echo 'nameserver 103.196.38.38' | sudo tee /etc/resolv.conf > /dev/null

# Execute the openssl command to generate certificates
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
  -keyout cert.key -out cert.crt -extensions ext  -config \
  <(echo "[req]";
    echo distinguished_name=req;
    echo "[ext]";
    echo "keyUsage=critical,digitalSignature,keyEncipherment";
    echo "extendedKeyUsage=serverAuth";
    echo "basicConstraints=critical,CA:FALSE";
    echo "subjectAltName=DNS:mail.$arg1,DNS:*.mail.$arg1";
    ) -subj "/CN=*.mail.$arg1"

# Display message to add TLSA record
echo "Please add the following TLSA record with the value:"
echo -n "_443._tcp TLSA " && echo -n "3 1 1 " && openssl x509 -in cert.crt -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | xxd -p -u -c 32

# Copy certificates to the specified locations with sudo
sudo cp cert.crt "/etc/ssl/certs/mail.$arg1"
sudo cp cert.key "/etc/ssl/private/mail.$arg1"

# Check Nginx configuration and restart Nginx service
nginx -t && sudo service nginx restart
