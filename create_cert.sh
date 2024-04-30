#!/bin/bash

# Check if argument is provided
if [ -z "$1" ]; then
  echo "Error: Please provide a domain name as an argument."
  exit 1
fi

# Define the domain name from argument
domain="$1"

# Generate the certificate and key using openssl
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
  -keyout cert.key -out cert.crt \
  -extensions ext \
  <(echo "[req]";
    echo distinguished_name=req;
    echo "[ext]";
    echo "keyUsage=critical,digitalSignature,keyEncipherment";
    echo "extendedKeyUsage=serverAuth";
    echo "basicConstraints=critical,CA:FALSE";
    echo "subjectAltName=DNS:mail.$domain,DNS:*.mail.$domain";
  ) -subj "/CN=*.mail.$domain"
  
echo "Please add the following TLSA record with the value:"
echo -n "_443._tcp " && echo -n "3 1 1 " && openssl x509 -in cert.crt -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | xxd -p -u -c 32

sudo cp cert.crt /etc/ssl/certs/mail.$domain.cert
sudo cp cert.key /etc/ssl/private/mail.$domain.key

echo "Certificate and key generated and set successfully!"
echo "Now run sudo nginx -t && sudo service nginx restart to check if there is any error"
