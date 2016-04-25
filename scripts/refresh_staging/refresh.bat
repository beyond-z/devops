#!/bin/bash
source ~/.env

read -r -p "Are you sure you want to blow away and refresh the staging servers using production? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

echo "Refreshing canvas staging portal (stagingportal.bebraven.org)"
~/scripts/refresh_staging/lms_refresh_db.bat
if [ $? -ne 0 ]
then
  echo "Failed refreshing canvas staging portal (stagingportal.bebraven.org)"
  echo "Make sure that you can connect to the staging and production databases from your machine:"
  echo "Staging: nc -cv $PORTAL_STAGING_DB_SERVER 5432"
  echo "Production: nc -cv $PORTAL_PROD_DB_SERVER 5432"
  echo "If you can't, you may have to add your IP address to the Security Group Inbound rules here: "
  echo "https://us-west-1.console.aws.amazon.com/ec2/v2/home?region=us-west-1#SecurityGroups:search=sg-4307b526;sort=groupId"
  exit 1
fi

echo "Copying Canvas files and images from production to staging"
~/scripts/refresh_staging/lms_refresh_files.bat
if [ $? -ne 0 ]
then
  echo "Failed copying Canvas files and images from production to staging"
  exit 1
fi


echo "Refreshing the website where people signup and apply (stagingjoin.bebraven.org)"
~/scripts/refresh_staging/join_refresh.bat
if [ $? -ne 0 ]
then
  echo "Failed refreshing public facing website (staging.bebraven.org)"
  exit 1
fi

echo "Pushing database dumps up to S3 bucket for development environment to access"
./scripts/refresh_staging/sync_db_dumps.bat
if [ $? -ne 0 ]
then
  echo "Failed pushing db dumps to $DB_DUMPS_S3_BUCKET Amazon S3 bucket"
  exit 1
fi

echo "NOTE: a script to refresh the public facing site, staging.bebraven.org hasn't been written yet.  You have to do that manually for now using teh updraftplus plugin"

else
  echo "Aborted!"
fi

