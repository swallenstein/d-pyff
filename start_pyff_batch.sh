#!/bin/sh
# entrypoint of the docker container

#     --logfile option not working; linking stdout to logfile instead (-> Dockerfile)
/usr/bin/pyff --loglevel=$LOGLEVEL $PIPELINEBATCH

