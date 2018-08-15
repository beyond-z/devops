#!/bin/bash
source ~/.env

# Have to use internal IP/DNS since firewall is setup to only allow internal connections
ssh $CAREER_MGR_PROD_USER
if [ $? -ne 0 ]
then
  echo "Failed connecting to $CAREER_MGR_PROD_USER Check that the URL is still accurate in the AWS console, and that the firewall is open for SSH connections from the AdminServer, and that the career-manager-prod.pem key was added to the ssh-agent below: `ssh-add -l`"
  exit 1;
fi
