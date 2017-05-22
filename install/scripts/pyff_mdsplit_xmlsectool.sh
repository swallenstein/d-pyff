#!/bin/bash
set -e
# create a signed XML file per EntityDescriptor for ADFS

# MDSIGN_CERT, MDSIGN_KEY and MDAGGREGATE must be passed via env
if [ ! -e "$MDSIGN_CERT" ]; then echo "MDSIGN_CERT must be set and point to an existing file" && exit 1; fi
if [ ! -e "$MDSIGN_KEY" ]; then echo "MDSIGN_KEY must be set and point to an existing file" && exit 1; fi
if [ ! -e "$MD_AGGREGATE" ]; then echo "MD_AGGREGATE must be set and point to an existing file" && exit 1; fi
# Setting defaults
if [ -z "$MDSPLIT_UNSIGNED" ]; then MDSPLIT_UNSIGNED='/var/md_source/split'; fi
if [ -z "$MDSPLIT_SIGNED" ]; then MDSPLIT_SIGNED='/var/md_feed/split'; fi
if [ -z "$LOGFILE" ]; then LOGFILE='/var/log/pyff_mdsplit.log'; fi



# Step 1. Split aggregate and create an XML and a pipeline file per EntityDescriptor
rm -rf $MDSPLIT_UNSIGNED/*
[ "$LOGLEVEL" == "DEBUG" ] && echo "processing md aggregate"
/usr/bin/pyff_mdsplit.py $* \
    --nocleanup \
    --nosign \
    --logfile $LOGFILE --loglevel DEBUG \
    $MD_AGGREGATE $MDSPLIT_UNSIGNED


# Step 2. Execute xmlsectool to sign each EntityDescriptor (ignoring pyff pipeline)
# Problem: pyff does not create signatures with exclusive c14n (http://www.w3.org/2001/10/xml-exc-c14n#)
# -> use xmlsectool for ADFS
cd $MDSPLIT_UNSIGNED
[ "$LOGLEVEL" == "DEBUG" ] && VERBOSE='--verbose'
mkdir -p $MDSPLIT_SIGNED
for fn in *; do
    [ "$LOGLEVEL" == "DEBUG" ] && echo "running xmlsectool for $fn"
    $XMLSECTOOL --sign --digest SHA-256 \
        --inFile 	$MDSPLIT_UNSIGNED/$fn/ed.xml \
        --outFile 	$MDSPLIT_SIGNED/$fn.xml \
        --key 		$MDSIGN_KEY \
        --certificate $MDSIGN_CERT $VERBOSE
done

# Step 3. Delete stale files (EDs removed from aggregate or failure to sign)
find $MDSPLIT_SIGNED -maxdepth 1 -mmin +59 -type f -name "*.xml" -exec rm -f {} \;

# Step 4. Make metadata files availabe to nginx container
chmod 644 $MDSPLIT_SIGNED/*.xml 2> /dev/null

# Step 5. Make metadata aggregate the default page in /entities
[[ -e "$MDSPLIT_SIGNED/.htaccess" ]] || echo 'Options +Indexes' > $MDSPLIT_SIGNED/.htaccess

