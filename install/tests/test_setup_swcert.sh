#!/usr/bin/env bash

main(){
    set -e
    prepare_test_config_sw_cert
    prepare_git_user
    prepare_mdfeed_repo
    create_sw_signing_cert
    create_git_ssh_keys
    create_mdfeed_repo
    echo 'Test setup completed'; echo
}


prepare_test_config_sw_cert() {
    echo 'Test setup 01: set test config and add mdsource data (not overwriting existing data)'
    cp -np  /opt/testdata/etc/pki/tls/openssl.cnf /etc/pki/tls/
    cp -np  /opt/testdata/etc/pyff/* /etc/pyff/
    cp -npr /opt/testdata/md_source/*.xml /var/md_source/

    echo 'copy config data'
    cp /opt/testdata/etc/pyff/mdx_discosign_swcert.fd-example /etc/pyff/mdx_discosign.fd
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
    echo 'Test setup 03: create local mdfeed repo '
    cd /var/md_feed
    git init
    git add --all
    touch .gitignore
    git commit -m 'empty'
}


create_sw_signing_cert() {
    echo 'Test setup 04: create MD signing certificate'
    /scripts/create_sw_cert.sh -p unittest
}


create_git_ssh_keys() {
    echo "Test setup 05: create SSH keys for access to $MDFEED_HOST"
    /scripts/gen_sshkey.sh
}


create_mdfeed_repo() {
    echo 'Test setup 06: mdfeed repo setup'
    /tests/init_mdfeed_local.sh
}


main "$@"