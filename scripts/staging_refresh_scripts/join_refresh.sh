#!/bin/bash
source ~/scripts/helper_functions.sh

################
# This script loads the latest Join DB snapshot from $HEROKU_S3_STAGING_DBS_BUCKET into the staging server DB.
################

exit_if_no_aws

cd ~/src/join/

echo "Creating link to latest Join staging DB snapshot"
# TODO: consolidate the naming of all the files b/n creating the snapshots and restoring the snapshots instead of hardcoding
# Link good for 5 min.
cmd_to_get_dump_url="aws s3 presign --expires-in 300 $join_latest_dump_s3_path"
dump_url_to_restore=`$cmd_to_get_dump_url` || { echo >&2 "Error: Failed getting public URL for $join_latest_dump_s3_path"; exit 1;}

echo "Restoring Join staging DB from latest snapshot"
heroku pg:backups:restore $dump_url_to_restore $HEROKU_STAGING_DB --app $HEROKU_STAGING_APP \
  || { echo >&2 "Error: Failed running heroku pg:backups:restore $dump_url_to_restore $HEROKU_STAGING_DB --app $HEROKU_STAGING_APP"; exit 1; }







##### SCRATCH #####

#################
## Below is code to do a live refresh from prod instead of a refresh from the latest backups.
## Seems like we'll want to do this at some point
#################
## Note: I was getting errors like this if I didn't reset the staging database first.
##  -- create_table(:salesforce_caches)
##  PG::DuplicateTable: ERROR:  relation "salesforce_caches" already exists
##  : CREATE TABLE "salesforce_caches" ("id" serial primary key, "key" character varying(255), "value" text, "created_at" timestamp, "updated_at" timestamp) 
##  rake aborted!
#heroku pg:reset DATABASE --app $HEROKU_STAGING_APP --confirm $HEROKU_STAGING_APP
#
## Connect to staging and transfer from production database
## Here is the generic version of the following command, old-app is production (where we transfer from)
## and new app is staging (where we transfer to):
##     heroku pgbackups:copy old-application::OLD_APP_DB_NAME NEW_APP_DB_NAME -a new-application
#echo "Refreshing stagingjoin.bebraven.org database from the production join.bebraven.org one"
#heroku pg:copy $HEROKU_PROD_APP::$HEROKU_PROD_DB $HEROKU_STAGING_DB -a $HEROKU_STAGING_APP --confirm $HEROKU_STAGING_APP --remote staging
#if [ $? -ne 0 ]
#then
#  echo "Failed refreshing database from production"
#  exit 1
#fi
#
#echo "Migrating the staging database in case there were schema changes"
#heroku run rake db:migrate --remote staging
#
#echo "Sanitizing all passwords in staging"
#echo "update users set encrypted_password = '$HEROKU_STAGING_ENCRYPTED_DEV_PASS';" | heroku pg:psql --app $HEROKU_STAGING_APP --remote staging

