#!/bin/bash
source ~/.env

cd ~/src/join/
git checkout salesforce_opentent_integration
git pull origin salesforce_opentent_integration

# update the ENV config on staging
cp .env-salesforce-opentent-integration .env
heroku config:push --overwrite --remote salesforce-opentent
if [ $? -ne 0 ]
then
  echo "Failed pushing .env config to heroku" 
  exit 1
fi

# Push the code
git push salesforce-opentent salesforce_opentent_integration:master
if [ $? -ne 0 ]
then
  echo "Failed pushing staging code to heroku" 
  exit 1
fi

# Reset heroku
#heroku run rake db:migrate db:seed --remote salesforce-opentent
#heroku pg:reset DATABASE --app $HEROKU_OPENTENT_APP --confirm $HEROKU_OPENTENT_APP

heroku run rake db:migrate --remote salesforce-opentent
if [ $? -ne 0 ]
then
  echo "Failed migrating database"
  exit 1
fi

heroku restart --remote salesforce-opentent
if [ $? -ne 0 ]
then
  echo "Failed restarting heroku app"
  exit 1
fi
