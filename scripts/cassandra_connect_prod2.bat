#!/bin/bash
source ~/.env

# Have to use internal IP/DNS since firewall is setup to only allow internal connections
ssh $CASSANDRA_SECONDARY_NODE_USER
if [ $? -ne 0 ]
then
  echo "Failed connecting to $CASSANDRA_SECONDARY_NODE_USER  Check that the canvas-lms.pem key was added to the ssh-agent using `ssh-add -l`"
  exit 1;
fi

