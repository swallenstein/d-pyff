#!/usr/bin/env bash

echo
lsof -i -P -sTCP:LISTEN
echo
ps -eaf | head -1
ps -eaf | grep ' /usr/bin/pyffd ' | grep -v ' grep '
echo