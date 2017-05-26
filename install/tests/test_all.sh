#!/usr/bin/env bash

echo '=== test_setup.sh ==='
/tests/test_setup.sh
echo; echo '=== test_pyffd_swcert.sh ==='
/tests/test_pyffd_swcert.sh
echo; echo '=== start_pkcs11_services.sh ==='
/scripts/start_pkcs11_services.sh
echo; echo '=== test_pyff_hsm.sh ==='
/tests/test_pyff_hsm.sh

