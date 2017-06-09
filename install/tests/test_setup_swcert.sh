#!/usr/bin/env bash

main() {
    set +e
    setup_logging
    prepare_test_config_sw_cert
    prepare_git_user
    prepare_mdfeed_repo
    create_sw_signing_cert
    create_git_ssh_keys
}


setup_logging() {
    SCRIPT=$(basename $0)
    SCRIPT=${SCRIPT%.*}
    LOGDIR="/tmp/${SCRIPT%.*}"
    mkdir -p $LOGDIR
    echo "    Logfiles in $LOGDIR"
    export LOGLEVEL=INFO
}


prepare_test_config_sw_cert() {
    echo 'Test setup 01: set test config and add metadata source data (not overwriting existing data)'
    cp -np  /opt/testdata/etc/pki/tls/openssl.cnf /etc/pki/tls/
    cp -np  /opt/testdata/etc/pyff/* /etc/pyff/
    cp -npr /opt/testdata/md_source/*.xml /var/md_source/
    cp /opt/testdata/etc/pyff/mdx_discosign_swcert.fd-example /etc/pyff/mdx_discosign.fd
    export PIPELINEDAEMON=/etc/pyff/mdx_discosign.fd
    cp /opt/testdata/etc/pyff/md_aggregator_sign_swcert.fd-example /etc/pyff/md_aggregator_sign_swcert.fd
    export PIPELINEBATCH=/etc/pyff/md_aggregator_sign_swcert.fd
}


prepare_git_user() {
    echo 'Test setup 02: setup git user'
    git config --global user.email "tester@testinetics.com"
    git config --global user.name "Unit Test"
    git config --global push.default simple
}


prepare_mdfeed_repo() {
    echo 'Test setup 03: create local mdfeed repo'
    cd /var/md_feed
    git init > $LOGDIR/prepare_mdfeed_repo.log
    git add --all >> $LOGDIR/prepare_mdfeed_repo.log
    touch .gitignore
    git commit -m 'empty' >> $LOGDIR/prepare_mdfeed_repo.log
}


create_sw_signing_cert() {
    echo 'Test setup 04: create MD signing certificate'
    /scripts/create_sw_cert.sh -p unittest
}


create_git_ssh_keys() {
    echo "Test setup 05: create SSH keys for access to $REPO_HOST"
    /scripts/gen_sshkey.sh > $LOGDIR/test05.log
    /tests/assert_nodiff.sh $LOGDIR/test05.log /opt/testdata/results/$SCRIPT/test05.log
}

main "$@"