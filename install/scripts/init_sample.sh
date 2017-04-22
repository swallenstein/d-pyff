#!/bin/sh
# container entrypoint for initializing mounted volumes with test data

echo "initailizing /etc/pki /etc/pyff /var/md_source with sample data"
if [ -d "/etc/pki/sign/metadata_signing-key.pem" ]; then
    echo "/etc/pki/sign/metadata_signing-key.pem already exists: stopping"
    exit 0
fi
mkdir -p /etc/pki/tls /etc/pki/sign
cp -p /opt/sample_data/etc/pki/tls/openssl.cnf  /etc/pki/tls/
openssl genrsa -out /etc/pki/sign/metadata_signing-key.pem 2048
openssl req -batch -new -key /etc/pki/sign/metadata_signing-key.pem \
             -out /etc/pki/sign/metadata_signing-csr.pem
openssl x509 -req -days 7200 -in /etc/pki/sign/metadata_signing-csr.pem \
             -signkey /etc/pki/sign/metadata_signing-key.pem \
             -out /etc/pki/sign/metadata_signing-crt.pem
cp -pr /opt/sample_data/etc/pyff/* /etc/pyff
cp -p  /etc/sign/md_aggregate_sign_swcert.fd-example /etc/pyff/md_aggregator.fd
cp -pr /opt/sample_data/test/metadata/*.xml /var/md_source
