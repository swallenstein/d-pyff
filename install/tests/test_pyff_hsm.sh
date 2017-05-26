#!/usr/bin/env bash

set -e

# test 20
echo 'Test 20: HSM'
if [[ -z ${PYKCS11LIB+x} ]]; then
    echo 'PYKCS11LIB not set - failed HSM test'
    exit 1
fi
if [[ -z ${PYKCS11PIN+x} ]]; then
    echo 'PYKCS11PIN not set - failed HSM test'
    exit 1
fi

echo 'copy config data (not overwriting existing data)'
cp -np  /opt/testdata/etc/pyff/md_aggregator_sign_hsm.fd-example /etc/pyff/md_aggregator.fd

# test 21
echo 'Test 21: create aggregate from test data'
/scripts/pyff_aggregate.sh
python /tests/check_metadata.py /var/md_feed/metadata.xml > /tmp/entities.list
diff /tmp/entities.list /opt/testdata/results/entities2.list

# test 22
echo 'Test 22: create aggregate from test data'
/scripts/pyff_aggregate.sh


# test 23
echo 'Test 23: create aggregate from test data + mdsplit + push git repo '
/scripts/pyff_aggregate.sh -g -S

# test 07
echo 'Test 07: status report '
/scripts/status.sh

echo 'Tests completed'
