#!/usr/bin/env bash

echo
netstat -tunap | head -2
netstat -tunap | egrep ':8080\s'
echo
ps -eaf | head -1
ps -eaf | grep ' /usr/bin/pyffd ' | grep -v ' grep '
echo