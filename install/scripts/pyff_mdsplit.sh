#!/bin/bash
set -e
# create a signed XML file per EntityDescriptor for ADFS

# MDSIGN_CERT, MDSIGN_KEY and MDAGGREGATE must be passed via env
if [ ! -e $MDSIGN_CERT ]; then echo "MDSIGN_CERT must be set and point to an existing file" && exit 1; fi
if [ ! -e $MDSIGN_KEY ]; then echo "MDSIGN_KEY must be set and point to an existing file" && exit 1; fi
if [ ! -e $MD_AGGREGATE ]|| echo "MD_AGGREGATE must be set and point to an existing file" && exit 1; fi
# Setting defaults
if [ ! -e $MDSPLIT_UNSIGNED ]; then MDSPLIT_UNSIGNED='/var/md_source/split/'; fi
if [ ! -e $MDSPLIT_SIGNED ]; then MDSPLIT_SIGNED='/var/md_feed/split/'; fi
if [ ! -e $LOGFILE ]; then LOGFILE='/var/log/pyffsplit.log'; fi


# Step 1. Split aggregate and create an XML and a pipeline file per EntityDescriptor
[ "$LOGLEVEL" == "DEBUG" ] && echo "processing "
/usr/bin/pyff_mdsplit.py \
    --certfile $CERTFILE --keyfile $KEYFILE \
    --outdir_signed pyff_split_sign_xmlsectool.sh \
    --logfile $LOGFILE --loglevel DEBUG \
    $MD_AGGREGATE $MDSPLIT_UNSIGNED

# Step 2. Execute pyff to sign each EntityDescriptor
chmod 644 $MDSPLIT_SIGNED/*.xml 2> /dev/null

