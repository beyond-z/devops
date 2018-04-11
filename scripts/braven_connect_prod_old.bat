#/bin/bash

source ~/.env

ssh $BRAVEN_PROD_OLD_USER
if [ $? -ne 0 ]
then
  echo "Failed connecting to $BRAVEN_PROD_OLD_USERCheck that the braven.pem key was added to the ssh-agent using `ssh-add -l`"
  exit 1;
fi
