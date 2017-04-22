#!/usr/bin/env sh

# needed for docker container. Full linux installation has dbus started,
# and pcscd should be started as well -> checkcfg --list
/bin/dbus-daemon --system || exit -1
# /usr/sbin/hald --daemon=yes || exit -1  # hal moved to udev
/usr/sbin/pcscd -c /etc/reader.conf || exit -1
