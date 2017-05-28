#!/usr/bin/env bash

LOGDIR=/tmp/$0.log
mkdir -p $LOGDIR
export LOGLEVEL=INFO

# test 21
echo "Test 21: create aggregate from test data. Pipeline: ${PIPELINEBATCH}"
/scripts/pyff_aggregate.sh
python /tests/check_metadata.py /var/md_feed/metadata.xml > /tmp/entities.list
diff /tmp/entities.list /opt/testdata/results/entities2.list
if (( $? != 0 )); then
    echo 'List of metadata entites does not match expected value. Expected:'
    cat /opt/testdata/results/entities2.list
    echo 'Found:'
    cat /tmp/entities.list
    exit 1
fi


# test 22
echo 'Test 22: verify metadata signature with xmlsectool'
/opt/xmlsectool-2/xmlsectool.sh --verifySignature --inFile /var/md_feed/metadata.xml \
    --certificate /etc/pki/sign/certs/metadata_crt.pem --whitelistDigest SHA-1 > $LOGDIR/test22.log
if (( $? != 0 )); then
    echo 'Metadata signature not valid'
    cat $LOGDIR/test22.log
    exit 1
fi


# test 23
echo "Test 23: create aggregate from test data + mdsplit + push git repo. Pipeline: ${PIPELINEBATCH}"
/scripts/pyff_aggregate.sh -g -S


# test 24
echo 'Test 24: status report '
/scripts/status.sh > $LOGDIR/test24.log
grep 'TCP \*:8080 (LISTEN)' $LOGDIR/test24.log > /dev/null
if (( $? != 0 )); then
    echo 'Status report: "TCP *:8080 (LISTEN)" not found'
    cat $LOGDIR/test24.log
    exit 1
fi

echo 'Tests completed'
