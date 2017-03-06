#!/usr/bin/env bash
set -e -o pipefail

# create a new signing certificate for the aggregator

main() {
    get_commandline_args
    create_cert
    list_cert
}

get_commandline_args() {
    USAGE=$(printf "%s\n" \
        "usage: $0 [-h] -n <cn> [-p]" \
        "  -h  print this help text" \
        "  -n  common name part of x509 subject" \
        "  -p  print command")

    while getopts ":p" opt; do
      case $opt in
        p) PRINT="True";;
        *) echo $USAGE; exit 0;;
      esac
    done
    shift $((OPTIND-1))
    if [ -z $1 ]; then
        echo 'missing argument "common name"'
        echo $USAGE
        exit 1
    fi
    CommonName=$1
}


create_cert() {
    cmd="openssl req -x509 -newkey rsa:4096
        -keyout /etc/pki/sign/private/metadata_key.pem
        -out /etc/pki/sign/certs/metadata_crt.pem
        -sha256
        -days 3650 -nodes
        -batch -subj '/C=AT/ST=Wien/L=Wien/O=Bildungsministerium/OU=IT/CN=$CommonName'
    "
    if [ "$PRINT" == "True" ]; then
        echo $cmd
    fi
    $cmd
}

list_cert() {
    openssl x509 -text -noout \
        -in /etc/pki/sign/certs/metadata_crt.pem \
        -certopt no_pubkey -certopt no_issuer -certopt no_sigdump
}


main