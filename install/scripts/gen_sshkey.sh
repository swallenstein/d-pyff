#!/usr/bin/env bash

if (( $(id -u) == 0 )); then
    echo "Do not start as root: ssh keys are required for the regular container user."
fi

if [[ ! -e ~/.ssh/id_ed25519 ]]; then
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ''
fi

# test connection and confirm host key
ssh -T $MDFEED_SSHUSER@$MDFEED_HOST

echo "created new public key - register with $MDFEED_HOST/$MDFEED_REPO:"
if [[ ! -e ~/.ssh/id_ed25519.pub ]]; then
    cat ~/.ssh/id_ed25519.pub
fi