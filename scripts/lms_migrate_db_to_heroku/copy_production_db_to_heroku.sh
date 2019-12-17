#!/bin/bash
source ~/.env
read -r -p "Are you sure you want to blow away the PRODUCTION database on Heroku and refresh it from the one on AWS? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

# Note: we don't have a prod db bucket. Just storing in the staging bucket since it's the same access rights and
# we'll likely delete these dumps when done with the migration

pg_dump --clean -Fc -h $PORTAL_PROD_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d $PORTAL_PROD_DB_NAME \
  | aws s3 cp - $PORTAL_S3_STAGING_DBS_BUCKET/prod_db_replica_for_heroku.dump \
  || { echo >&2 "Error: Failed dumping Prod DB and storing on S3"; exit 1; }

prod_db_url=`aws s3 presign $PORTAL_S3_STAGING_DBS_BUCKET/prod_db_replica_for_heroku.dump` \
  || { echo >&2 "Error: Failed getting signed Prod DB URL"; exit 1; }

echo "heroku pg:backups:restore $prod_db_url DATABASE_URL --app portal-bebraven-dot-org"
heroku pg:backups:restore "$prod_db_url" DATABASE_URL --app portal-bebraven-dot-org --confirm portal-bebraven-dot-org \
  || { echo >&2 "Error: Failed restoring Heroku DB from Prod DB"; exit 1; }

else
  echo "Aborted!"
fi


# NOTE:
# Before writing this script, I verified that there are no globals we need to bring across
# pg_dumpall -h $PORTAL_PROD_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -g 
# SET default_transaction_read_only = off;
# SET client_encoding = 'UTF8';
# SET standard_conforming_strings = on;
