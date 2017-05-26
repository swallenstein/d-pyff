#!/usr/bin/env bash

/tests/test_setup.sh
/tests/test_pyffd_swcert.sh
/scripts/start_pkcs11_services.sh
/tests/test_pyff_hsm.sh


