#!/usr/bin/env bash

set -e

echo 'copy test data (not overwriting existing data)'
cp -np  /opt/sample_data/etc/pki/tls/openssl.cnf /etc/pki/tls/
cp -np  /opt/sample_data/etc/pyff/* /etc/pyff/
cp -np  /etc/sign/md_aggregate_sign_swcert.fd-example /etc/pyff/md_aggregator.fd
cp -npr /opt/sample_data/testdata/md_source/*.xml /var/md_source

# test 01
echo 'create MD signing certificate'
/create_sw_cert.sh -p unittest

# test 02
echo 'starting pyffd and expecting html response'
/start_pyffd.sh && sleep 1
curl http://localhost:8080/ | grep '<title>pyFF @ localhost:8080</title>'

# test 03
echo "create SSH keys for access to $MDFEED_HOST"
/gen_sshkey.sh

# test 04
echo 'clone local git repo for md_feed '
rm -rf /tmp/md_feed || true
mkdir -p /tmp/md_feed
cd /tmp/md_feed
git config --global user.email "tester@testinetics.com"
git config --global user.name "Unit Test"
git config --global push.default simple
git --bare init
cd /var/md_feed
git clone /tmp/md_feed .


echo 'create aggregate from test data and push repo'
/pyff_aggregate.sh
/git_push.sh
