#!/bin/sh
# container entrypoint for initializing mounted volumes with test data

echo "initailizing /etc/pki /etc/pyff /var/md_source with sample data"
cp -pr /opt/sample_data/etc/pki/* /etc/pki
cp -pr /opt/sample_data/etc/pyff/* /etc/pyff
cp -p /etc/pyff/md_aggregate_sign_swcert.fd-example/etc/pyff/md_aggregate_sign.fd
cp -pr /opt/sample_data/var/md_source /var
