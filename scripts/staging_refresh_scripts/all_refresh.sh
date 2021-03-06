#!/bin/bash
source ~/scripts/helper_functions.sh

read -r -p "Are you sure you want to blow away and refresh the staging servers using production? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

echo "### Refreshing the staging Portal aka Canvas: https://stagingportal.bebraven.org)"
~/scripts/staging_refresh_scripts/lms_refresh.bat
  || { echo >&2 "Error: Failed refreshing the staging Portal server (stagingportal.bebraven.org)"; exit 1; }
echo "### Done: Refreshing the staging Portal aka Canvas: https://stagingportal.bebraven.org)"

echo "### Refreshing the staging Join server: https://stagingjoin.bebraven.org"
~/scripts/staging_refresh_scripts/join_refresh.sh \
  || { echo >&2 "Error: Failed refreshing the staging Join server (stagingjoin.bebraven.org)"; exit 1; }
echo "### Done: Refreshing the staging Join server: https://stagingjoin.bebraven.org"

echo "### Refreshing the staging Kits server: https://stagingkits.bebraven.org"
~/scripts/staging_refresh_scripts/kits_refresh.sh \
  || { echo >&2 "Error: Failed refreshing the staging Kits server (stagingkits.bebraven.org)"; exit 1; }
echo "### Done: Refreshing the staging Kits server: https://stagingkits.bebraven.org"

echo "### Refreshing the staging public facing website: https://staging.bebraven.org"
~/scripts/staging_refresh_scripts/bebraven_refresh.sh \
  || { echo >&2 "Error: Failed refreshing the public facing website (staging.bebraven.org)"; exit 1; }
echo "### Done: Refreshing the staging public facing website: https://staging.bebraven.org"

########################################################################################
############ Done with refresh. Print out any followup instructions. ###############
########################################################################################

echo "### IMPORTANT: you have to login to the Join admin dashboard and upload the signup_options_campaign_mapping_staging.csv file from Google Drive!!!"

else
  echo "Aborted!"
fi

