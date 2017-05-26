#!/usr/bin/env bash

set -e

echo "copy test data (not overwriting existing data)"
cp -np  /opt/testdata/etc/pki/tls/openssl.cnf /etc/pki/tls/
cp -np  /opt/testdata/etc/pyff/* /etc/pyff/
if [[ ! -z ${PYKCS11LIB+x} ]]; then
    cp -np  /opt/testdata/etc/pyff/md_aggregator_sign_hsm.fd-example /etc/pyff/md_aggregator.fd
else
    cp -np  /opt/testdata/etc/pyff/md_aggregator_sign_swcert.fd-example /etc/pyff/md_aggregator.fd
fi
cp -npr /opt/testdata/md_source/*.xml /var/md_source

# test 01
echo 'Test 01: create MD signing certificate'
/scripts/create_sw_cert.sh -p unittest

# test 02
echo 'Test 02: starting pyffd and expecting html response'
/scripts/start_pyffd.sh &
sleep 3
curl --silent http://localhost:8080/ | grep '<title>pyFF @ localhost:8080</title>' > /tmp/entities.list
diff /tmp/entities.list /opt/testdata/results/entities1.list

# test 03
echo "Test 03: create SSH keys for access to $MDFEED_HOST"
/scripts/gen_sshkey.sh

# test 04
echo 'Test 04: clone local git repo for md_feed '
rm -rf /tmp/md_feed 2>/dev/null || true
mkdir -p /tmp/md_feed
cd /tmp/md_feed
git config --global user.email "tester@testinetics.com"
git config --global user.name "Unit Test"
git config --global push.default simple
git --bare init
rm -rf /var/md_feed 2>/dev/null || true
cd /var/md_feed
git clone /tmp/md_feed .

# test 05
echo 'Test 05: create aggregate from test data'
/scripts/pyff_aggregate.sh
python /tests/check_metadata.py /var/md_feed/metadata.xml > /tmp/entities.list
diff /tmp/entities.list /opt/testdata/results/entities2.list

# test 06
echo 'Test 06: create aggregate from test data + mdsplit push git repo '
/scripts/pyff_aggregate.sh -g -S

# test 07
echo 'Test 07: status report '
/scripts/status.sh

echo 'Tests completed'
