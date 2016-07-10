#!/bin/sh
# create a signed XML file per EntityDescriptor for ADFS
# -> use xmlsectool to create signatures with exclusive c14n (http://www.w3.org/2001/10/xml-exc-c14n#)

MDAGGREGATE='/var/md_feed/metadata.xml'
MDSPLITUNSIGNED='/var/md_source/split/'
MDSPLITSIGNED='/var/md_feed/split/'
CERTFILE='/etc/pki/pyff/metadata_signing-crt.pem'
KEYFILE='/etc/pki/pyff/metadata_signing-key.pem'
LOGFILE='/var/log/pyffsplit.log'
XMLSECTOOL='/opt/xmlsectool-2/xmlsectool.sh'


# Step 1. Split aggregate and create an XML and a pipeline file per EntityDescriptor
[ "$LOGLEVEL" == "DEBUG" ] && echo "processing "
/usr/bin/mdsplit.py \
    -c $CERTFILE -k $KEYFILE \
    -l $LOGFILE -L DEBUG \
    $MDAGGREGATE $MDSPLITUNSIGNED $MDSPLITSIGNED


# Step 2. Execute pyff to sign each EntityDescriptor (using xmlsectool, ignoring pipeline)
cd $MDSPLITUNSIGNED
[ "$LOGLEVEL" == "DEBUG" ] && VERBOSE='--verbose'
for fn in *.xml; do
    [ "$LOGLEVEL" == "DEBUG" ] && echo "running xmlsectool for $fn"
    $XMLSECTOOL --sign --digest SHA-256 \
        --inFile 	$MDSPLITUNSIGNED/$fn \
        --outFile 	$MDSPLITSIGNED/$fn \
        --key 		$KEYFILE \
        --certificate $CERTFILE $VERBOSE
done

# Step 2. Make metadata files availabe to nginx container
chmod 644 $MDSPLITSIGNED/*.xml 2> /dev/null

