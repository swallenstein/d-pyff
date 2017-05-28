#!/usr/bin/env bash


# test 21
echo 'Test 21: create aggregate from test data'
/scripts/pyff_aggregate.sh
python /tests/check_metadata.py /var/md_feed/metadata.xml > /tmp/entities.list
diff /tmp/entities.list /opt/testdata/results/entities2.list

# test 22
echo 'Test 22: verify metadata signature with xmlsectool'
/opt/xmlsectool-2/xmlsectool.sh --verifySignature --inFile /var/md_feed/metadata.xml \
    --certificate /etc/pki/sign/certs/metadata_crt.pem --whitelistDigest SHA-1
if (( $? > 0 )); then
    echo 'Metadata signature not valid'
    exit 1
fi


# test 23
echo 'Test 23: create aggregate from test data + mdsplit + push git repo '
/scripts/pyff_aggregate.sh -g -S

# test 07
echo 'Test 07: status report '
/scripts/status.sh

echo 'Tests completed'
