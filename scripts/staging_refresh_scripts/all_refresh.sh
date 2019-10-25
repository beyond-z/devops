#!/bin/bash
source ~/scripts/helper_functions.sh

read -r -p "Are you sure you want to blow away and refresh the staging servers using production? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

# TODO: i commented out what nees to be cutover and uncommented what is done.

# TODO: cut me over to two phase approach. Automated nightly snapshots. Separately, refresh happens
# on demand from the latest snapshot

#echo "Refreshing the staging Portal aka Canvas: https://stagingportal.bebraven.org)"
#~/scripts/refresh_staging/lms_refresh_db.bat
#if [ $? -ne 0 ]
#then
#  echo "Failed refreshing the staging Portal"
#  echo "Make sure that you can connect to the staging and production databases from your machine:"
#  echo "Staging: nc -cv $PORTAL_STAGING_DB_SERVER 5432"
#  echo "Production: nc -cv $PORTAL_PROD_DB_SERVER 5432"
#  echo "If you can't, you may have to add your IP address to the Security Group Inbound rules here: "
#  echo "https://us-west-1.console.aws.amazon.com/ec2/v2/home?region=us-west-1#SecurityGroups:search=sg-4307b526;sort=groupId"
#  exit 1
#fi
#
#echo "Copying Canvas files and images from production to staging"
#~/scripts/refresh_staging/lms_refresh_files.bat
#if [ $? -ne 0 ]
#then
#  echo "Failed copying Canvas files and images from production to staging"
#  exit 1
#fi

echo "Refreshing the staging Join server: https://stagingjoin.bebraven.org"
~/scripts/staging_refresh_scripts/join_refresh.sh \
  || { echo >&2 "Error: Failed refreshing the staging Join server (stagingjoin.bebraven.org)"; exit 1; }


# TODO: cut me over to two phase approach. Automated nightly snapshots. Separately, refresh happens
# on demand from the latest snapshot

#echo "Refreshing the staging Kits server: https://stagingkits.bebraven.org"
#~/scripts/refresh_staging/kits_refresh.bat
#if [ $? -ne 0 ]
#then
#  echo "Failed refreshing the staging Kits server (stagingkits.bebraven.org)"
#  exit 1
#fi

########################################################################################
############ Done with refresh. Let them know anything they need to know. ###############

echo "NOTE: a script to refresh the public facing site, staging.bebraven.org hasn't been written yet.  You have to do that manually for now using teh updraftplus plugin"
echo ""
echo "### IMPORTANT: you have to login to the Join admin dashboard and upload the signup_options_campaign_mapping_staging.csv file from Google Drive!!!"

else
  echo "Aborted!"
fi

