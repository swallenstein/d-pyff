#!/usr/bin/env sh

Use this script if the pyff is only used as an aggregator


# needed for PKCS#11 devices

# /bin/dbus-daemon --system || exit -1

if [[ "$PYKCS11LIB" ]]; then
    sudo /usr/sbin/pcscd
fi


tail -f /dev/null