#!/usr/bin/env sh

# needed for PKCS#11 devices

# /bin/dbus-daemon --system || exit -1

if [[ "$PYKCS11LIB" ]]; then
    sudo /usr/sbin/pcscd
fi