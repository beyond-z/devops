#!/bin/bash

source ~/.env

now=$(date +"%Y-%m-%d.%H%M")
PROD_LOG=/var/canvas/current/log/production.log
LOCAL_LOG=~/logs/canvas/production_$now.log

echo "Copying $PROD_LOG locally $LOCAL_LOG"
echo "scp $PORTAL_PROD_USER:$PROD_LOG $LOCAL_LOG"
echo ""
scp -C $PORTAL_PROD_USER:$PROD_LOG $LOCAL_LOG
if [ $? -ne 0 ]
then
  echo "Failed copying canvas production log locally"
  exit 1
fi
