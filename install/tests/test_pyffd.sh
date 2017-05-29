#!/usr/bin/env bash

SCRIPT=$(basename $0)
LOGDIR="/tmp/${SCRIPT%.*}"
mkdir -p $LOGDIR

set +e

# test 10
echo 'Test 10: starting pyffd and expecting html response'
export LOGLEVEL=INFO
/scripts/start_pyffd.sh &
sleep 2
curl --silent http://localhost:8080/ | grep '<title>pyFF @ localhost:8080</title>' > /tmp/test10.log
/tests/assert_nodiff.sh $LOGDIR/test10.log /opt/testdata/results/$SCRIPT/test10.log

# test 11
echo 'Test 11: clone local git repo for md_feed '
rm -rf /tmp/md_feed 2>/dev/null || true
mkdir -p /tmp/md_feed
cd /tmp/md_feed
git config --global user.email "tester@testinetics.com"
git config --global user.name "Unit Test"
git config --global push.default simple
git --bare init > $LOGDIR/test11.log
rm -rf /var/md_feed 2>/dev/null || true
cd /var/md_feed
git clone /tmp/md_feed . >> $LOGDIR/test11.log
/tests/assert_nodiff.sh $LOGDIR/test11.log /opt/testdata/results/$SCRIPT/test11.log


