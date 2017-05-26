#!/usr/bin/env bash

set -e

echo 'copy test config and source data (not overwriting existing data)'
cp -np  /opt/testdata/etc/pki/tls/openssl.cnf /etc/pki/tls/
cp -np  /opt/testdata/etc/pyff/* /etc/pyff/
cp -npr /opt/testdata/md_source/*.xml /var/md_source

# test 01
echo 'Test 01: create MD signing certificate'
/scripts/create_sw_cert.sh -p unittest

# test 02
echo "Test 03: create SSH keys for access to $MDFEED_HOST"
/scripts/gen_sshkey.sh

# test 03
echo 'Test 03: mdfeed repo setup '
/scripts/init_mdfeed.sh

# test 04
echo 'Test 04: status report '
/scripts/status.sh

echo 'Test setup completed'
