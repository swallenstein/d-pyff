#!/usr/bin/env sh

# needed for PKCS#11 devices

/bin/dbus-daemon --system || exit -1

/usr/sbin/pcscd -c /etc/reader.conf || exit -1
