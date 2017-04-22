#!/usr/bin/env bash

ssh-keygen -t ECDSA -f ~/.ssh/id_ecdsa -N ''
if [ -z ~/.ssh/config ]; then
    echo "Host frontendhost" > ~/.ssh/config
    echo "HostName $FRONTEND_HOST" >> ~/.ssh/config
    echo "Port $FRONTEND_SSHPORT" >> ~/.ssh/config
fi

# test connection and confirm host key
ssh -T $FRONTEND_SSHUSER@$FRONTEND_HOST