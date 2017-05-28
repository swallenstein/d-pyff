#!/usr/bin/env bash

export USERPIN=$PYKCS11PIN
export PKCS11_CARD_DRIVER=$PYKCS11LIB

echo '=== test_setup_swcert.sh ==='
/tests/test_setup_swcert.sh

echo; echo '=== test_pyffd.sh ==='
/tests/test_pyffd.sh

echo; echo '=== start_pkcs11_services.sh ==='
/scripts/start_pkcs11_services.sh

echo; echo '=== test_hsm_token.sh ==='
/tests/test_hsm_token.sh

echo; echo '=== container status report ==='
/scripts/status.sh


HSMUSBDEVICE='Aladdin Knowledge Systems Token JC'  # output of lsusb
HSMP11DEVICE='eToken 5110'                         # output of pkcs11-tool --list-token-slots
lsusb | grep "$HSMUSBDEVICE"
if (( $? > 0 )); then
    echo 'HSM USB Device not found - skipping HSM tests'
    exit 1
fi

echo '=== test_setup_swcert.sh ==='
/tests/test_setup_hsm.sh

echo '=== test_setup_hsm.sh ==='
/tests/test_hsm_token.sh
