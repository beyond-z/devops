#!/bin/bash
source ~/.env

cd ~/src/join/
git checkout staging
git pull origin staging

# update the ENV config on staging
cp .env-staging .env
heroku config:push --overwrite --remote staging
if [ $? -ne 0 ]
then
  echo "Failed pushing .env config to heroku" 
  exit 1
fi

# Push the code
git push staging staging:master
if [ $? -ne 0 ]
then
  echo "Failed pushing staging code to heroku" 
  exit 1
fi

# Reset heroku
#heroku run rake db:migrate db:seed
#heroku pg:reset DATABASE --app $HEROKU_STAGING_APP --confirm $HEROKU_STAGING_APP

heroku run rake db:migrate --remote staging
if [ $? -ne 0 ]
then
  echo "Failed migrating database"
  exit 1
fi

heroku restart --remote staging
if [ $? -ne 0 ]
then
  echo "Failed restarting heroku app"
  exit 1
fi
