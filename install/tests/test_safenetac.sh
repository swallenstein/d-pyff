#!/usr/bin/env bash
#set -e -o pipefail

main() {
    start_pcscd
    init_sudo
    test_carddriver_setting
    dump_pkcs11_info
    exec bash
}


start_pcscd() {
    init_sudo
    echo
    echo "=== Starting Smartcard Service ==="
    $sudo /usr/sbin/pcscd
}


init_sudo() {
    if [ $(id -u) -ne 0 ]; then
        sudo="sudo"
    fi
}


test_carddriver_setting() {
    if [[ -z "$PKCS11_CARD_DRIVER" ]]; then
        echo "Env variable PKCS11_CARD_DRIVER not set"
        exit 1
    fi
}


dump_pkcs11_info() {
    echo
    echo "=== dump pkcs11 info ==="
    pkcs11-tool --module $PKCS11_CARD_DRIVER --show-info
    pkcs11-tool --module $PKCS11_CARD_DRIVER --list-slots
    #pkcs11-tool --module $PKCS11_CARD_DRIVER --list-mechanisms
}


main
