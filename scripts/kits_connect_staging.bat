#/bin/bash

source ~/.env

ssh $KITS_STAGING_USER
if [ $? -ne 0 ]
then
  echo "Failed connecting to $KITS_STAGING_USER Check that the kits_staging.pem key was added to the ssh-agent using `ssh-add -l`"
  exit 1;
fi
