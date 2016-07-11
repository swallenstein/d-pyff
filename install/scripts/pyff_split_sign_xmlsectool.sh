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
/usr/bin/mdsplit.py \
    -c $CERTFILE -k $KEYFILE \
    -l $LOGFILE -L DEBUG \
    $MD_AGGREGATE $MDSPLIT_UNSIGNED $MDSPLIT_SIGNED


# Step 2. Execute pyff to sign each EntityDescriptor
#cd /var/md_source/split/
#for fn in *.fd; do
#    echo "running pyff for $fn"
#    /usr/bin/pyff --loglevel=$LOGLEVEL $fn
#done

# Step 2. Execute xmlsectool to sign each EntityDescriptor (ignoring pyff pipeline)
# Problem: pyff does not create signatures with exclusive c14n (http://www.w3.org/2001/10/xml-exc-c14n#)
# -> use xmlsectool for ADFS

cd $MDSPLIT_UNSIGNED
[ "$LOGLEVEL" == "DEBUG" ] && VERBOSE='--verbose'
mkdir -p $MDSPLIT_SIGNED
for fn in *.xml; do
    [ "$LOGLEVEL" == "DEBUG" ] && echo "running xmlsectool for $fn"
    $XMLSECTOOL --sign --digest SHA-256 \
        --inFile 	$MDSPLIT_UNSIGNED/$fn \
        --outFile 	$MDSPLIT_SIGNED/$fn \
        --key 		$MDSIGN_KEY \
        --certificate $MDSIGN_CERT $VERBOSE
done

# Step 3. Make metadata files availabe to nginx container
chmod 644 $MDSPLIT_SIGNED/*.xml 2> /dev/null

