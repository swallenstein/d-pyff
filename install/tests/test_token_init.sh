#!/usr/bin/env bash

# TEST: initialize eToken with a key pair
# (in production the keys are imported with the SAC tool)

echo ***Initializing Token***
pkcs11-tool --module /usr/lib64/libeToken.so --init-token --label test --pin secret1 --so-pin secret2 || exit -1
echo ***Initializing User PIN***
pkcs11-tool --module /usr/lib64/libeToken.so -l --init-pin --pin secret1 --so-pin secret2
echo ***Generating RSA key***
pkcs11-tool --module /usr/lib64/libeToken.so -l -k --key-type rsa:2048 -d 1 --label test --pin secret1 || exit -1
echo ***Checking objects on eToken***
pkcs11-tool --module /usr/lib64/libeToken.so -l -O --pin secret1 || exit -1
echo ***Testing with pyFF***
echo ****XML from hoerbe.at****
export PYKCS11PIN=secret1
pyff /opt/sac/tests/test-yaml
#echo ***Testing with pyFF***
#echo ****XML from swamid.se****
#pyff /opt/sac/tests/test-swamid-yaml
