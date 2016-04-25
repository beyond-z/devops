#/bin/bash

ssh $OSQA_KNOWLEDGEBASE_USER
if [ $? -ne 0 ]
then
  echo "Failed connecting to $OSQA_KNOWLEDGEBASE_USER Check that the bitnami-do-6744bc4a3ef6328274ff876bd0ade1615b4b02e6.pem key was added to the ssh-agent using `ssh-add -l`"
  exit 1;
fi
