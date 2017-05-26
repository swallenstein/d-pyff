#!/usr/bin/env bash

set -e

echo 'Prep01: set test config and add mdsource data (not overwriting existing data)'
cp -np  /opt/testdata/etc/pki/tls/openssl.cnf /etc/pki/tls/
cp -np  /opt/testdata/etc/pyff/* /etc/pyff/
cp -npr /opt/testdata/md_source/*.xml /var/md_source/


echo 'Prep02: setup git user'
git config --global user.email "tester@testinetics.com"
git config --global user.name "Unit Test"
git config --global push.default simple


echo 'Prep03: create local mdfeed repo '
cd /var/md_feed
git init
git add --all
touch .gitignore
git commit -m 'empty'


# test 01
echo 'Test 01: create MD signing certificate'
/scripts/create_sw_cert.sh -p unittest

# test 02
echo "Test 03: create SSH keys for access to $MDFEED_HOST"
/scripts/gen_sshkey.sh

# test 03
echo 'Test 03: mdfeed repo setup '
/tests/init_mdfeed_local.sh

# test 04
echo 'Test 04: status report '
/scripts/status.sh

echo 'Test setup completed'
