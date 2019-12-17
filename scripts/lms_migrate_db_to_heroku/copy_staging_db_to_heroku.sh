#!/bin/bash
source ~/.env

pg_dump --clean -Fc -h $PORTAL_STAGING_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d $PORTAL_PROD_DB_NAME \
  | aws s3 cp - $PORTAL_S3_STAGING_DBS_BUCKET/staging_db_replica_for_heroku.dump \
  || { echo >&2 "Error: Failed dumping Staging DB and storing on S3"; exit 1; }

staging_db_url=`aws s3 presign $PORTAL_S3_STAGING_DBS_BUCKET/staging_db_replica_for_heroku.dump` \
  || { echo >&2 "Error: Failed getting signed Staging DB URL"; exit 1; } 

echo "heroku pg:backups:restore $staging_db_url DATABASE_URL --app stagingportal-bebraven-dot-org"
heroku pg:backups:restore "$staging_db_url" DATABASE_URL --app stagingportal-bebraven-dot-org --confirm stagingportal-bebraven-dot-org \
  || { echo >&2 "Error: Failed restoring Heroku DB from Staging DB"; exit 1; } 



# NOTE: 
# Before writing this script, I verified that there are no globals we need to bring across
# pg_dumpall -h $PORTAL_STAGING_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -g > /tmp/staging_globals_only.sql
# SET default_transaction_read_only = off;
# SET client_encoding = 'UTF8';
# SET standard_conforming_strings = on;
