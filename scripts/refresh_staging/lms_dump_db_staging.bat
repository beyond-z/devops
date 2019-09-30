#!/bin/bash
source ~/.env

now=$(date +"%Y%m%d")
db_dump_staging_file=~/dumps/lms_staging_db_dump_$now.sql
pg_dump --clean -h $PORTAL_STAGING_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d $PORTAL_PROD_DB_NAME > $db_dump_staging_file

if [ $? -ne 0 ]
then
  echo "Failed taking Canvas database dump from staging"
  echo ""
  echo "Double check that you have a ~/.pgpass file with credentials to connect to the staging and prod databases. Note that the ~/.pgpass file should have permissions set to chmod 600.  Example of file contents:"
  echo "$PORTAL_STAGING_DB_SERVER:5432:*:$PORTAL_PROD_DB_USER:yourPass"
fi
