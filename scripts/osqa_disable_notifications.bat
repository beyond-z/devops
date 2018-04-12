#!/bin/bash

source ~/.env

emailsToDisable='brian%2Btestdisableemail1%40bebraven.org,brian%2Btestdisableemail2%40bebraven.org'

echo "NOTE: before running, update this script to have the list of emails to disable"
echo "Here is the current list: $emailsToDisable"

read -r -p "Are you sure you want to run this? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
  curl -v "http://join.bebraven.org/salesforce/disable_osqa_notification_emails?magic_token=$HEROKU_SALESFORCE_MAGIC_TOKEN&emails=$emailsToDisable"
  if [ $? -ne 0 ]
  then
    echo "Failed disabling notifications for these users"
    exit 1;
  fi
else
  echo "Aborted!"
fi
