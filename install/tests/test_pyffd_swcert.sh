#!/usr/bin/env bash

set -e

# test 10
echo 'Test 10: starting pyffd and expecting html response'
/scripts/start_pyffd.sh &
sleep 3
curl --silent http://localhost:8080/ | grep '<title>pyFF @ localhost:8080</title>' > /tmp/entities.list
diff /tmp/entities.list /opt/testdata/results/entities1.list

# test 11
echo 'Test 11: clone local git repo for md_feed '
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

