#/bin/bash

source ~/.env

ssh $EDITOR_PROD_USER
if [ $? -ne 0 ]
then
  echo "Failed connecting to $EDITOR_PROD_USER Check that .ssh/config points to the proper ssh key"
  exit 1;
fi
