#!/bin/sh
# entrypoint of the docker container
# use this script if you do not need

if (( $(id -u) == 0 )); then
    echo "Do not start as root."
fi


#     --logfile option not working; linking stdout to logfile instead (-> Dockerfile)
/usr/bin/pyff --loglevel=$LOGLEVEL $PIPELINEBATCH

# make metadata files availabe to nginx container:
chmod 644 /var/md_feed/*.xml 2> /dev/null
