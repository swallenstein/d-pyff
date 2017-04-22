#!/usr/bin/env bash

ssh-keygen -t ECDSA -f ~/.ssh/id_ecdsa -N ''
if [ -z ~/.ssh/config ]; then
    echo "Host frontendhost" > ~/.ssh/config
    echo "HostName $MDFEED_HOST" >> ~/.ssh/config
fi

# test connection and confirm host key
ssh -T $MDFEED_SSHUSER@$MDFEED_HOST