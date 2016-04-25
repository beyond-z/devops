#!/bin/bash
source ~/.env

# Have to use internal IP/DNS since firewall is setup to only allow internal connections
ssh $SSO_PROD_USER 
if [ $? -ne 0 ]
then
  echo "Failed connecting to $SSO_PROD_USER Check that the sso-rubycas.pem key was added to the ssh-agent using `ssh-add -l`"
  exit 1;
fi
