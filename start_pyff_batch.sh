#!/bin/sh
# entrypoint of the docker container

#     --logfile option not working; linking stdout to logfile instead (-> Dockerfile)
/usr/bin/pyff --loglevel=$LOGLEVEL $PIPELINEBATCH

# make metadata files availabe to nginx container:
chmod 644 $VOLROOT/var/md_feed/*.xml