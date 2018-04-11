#/bin/bash

source ~/.env

ssh $BRAVEN_STAGING_OLD_USER
if [ $? -ne 0 ]
then
  echo "Failed connecting to $BRAVEN_STAGING_OLD_USER Check that the braven_staging.pem key was added to the ssh-agent using `ssh-add -l`"
  exit 1;
fi
