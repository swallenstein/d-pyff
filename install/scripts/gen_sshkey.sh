#!/usr/bin/env bash

if (( $(id -u) == 0 )); then
    echo "Do not start as root: ssh keys are required for the regular container user."
fi

if [[ ! -e ~/.ssh/id_ecdsa ]]; then
    ssh-keygen -t ECDSA -f ~/.ssh/id_ecdsa -N ''
fi

# test connection and confirm host key
ssh -T $MDFEED_SSHUSER@$MDFEED_HOST

echo "created new public key - register with $MDFEED_HOST/$MDFEED_REPO:"
cat ~/.ssh/id_ecdsa.pub