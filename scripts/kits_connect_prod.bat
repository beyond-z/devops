#/bin/bash

source ~/.env

ssh $KITS_PROD_USER
if [ $? -ne 0 ]
then
  echo "Failed connecting to $KITS_PROD_USER Check that the kits.pem key was added to the ssh-agent using `ssh-add -l`"
  exit 1;
fi
