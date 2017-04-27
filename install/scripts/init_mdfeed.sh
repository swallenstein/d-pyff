#!/usr/bin/env bash


git config --global user.email "tester@testinetics.com"
git config --global user.name "Unit Test"
git config --global push.default simple

cd /var/md_feed

echo "git clone $MDFEED_SSHUSER@$MDFEED_HOST:$MDFEED_REPO ."
git clone $MDFEED_SSHUSER@$MDFEED_HOST:$MDFEED_REPO .
