#!/usr/bin/env bash

echo 'Test setup HSM: set test config and add mdsource data (not overwriting existing data)'
cp /opt/testdata/etc/pyff/md_aggregator_sign_hsm.fd-example /etc/pyff/md_aggregator_sign_hsm.fd
export PIPELINEBATCH=/etc/pyff/md_aggregator_sign_hsm.fd

