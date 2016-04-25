#/bin/bash
source ~/.env

echo "NOTE: if you're using redis-cli to connect, make sure the firewall is open.  We locked it down to prevent unauthorized access after it kept going down."

# Have to use internal IP/DNS since firewall is setup to only allow internal connections
ssh $REDIS_PROD_USER
if [ $? -ne 0 ]
then
  echo "Failed connecting to $REDIS_PROD_USER Check that the canvas-lms.pem key was added to the ssh-agent using `ssh-add -l`"
  exit 1;
fi
