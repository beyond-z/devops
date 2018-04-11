#!/bin/bash
source ~/.env

db_dump_staging_file=staging_db_dump_2016-09-30.1328.sql
dropdb -h $PORTAL_STAGING_UPGRADE_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w $PORTAL_PROD_DB_NAME
createdb -h $PORTAL_STAGING_UPGRADE_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w $PORTAL_PROD_DB_NAME --owner=canvas
psql -h $PORTAL_STAGING_UPGRADE_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d $PORTAL_PROD_DB_NAME -f $db_dump_staging_file

if [ $? -ne 0 ]
then
  echo "Failed transfering local Canvas database to staging upgrade server."
  echo ""
  echo "Double check that you've dumped the staging database to $db_dump_staging_file"
  echo "Double check that you have a ~/.pgpass file with credentials to connect to the staging upgrade. Note that the ~/.pgpass file should have permissions set to chmod 600.  Example of file contents:"
  echo "$PORTAL_STAGING_UPGRADE_DB_SERVER:5432:*:$PORTAL_PROD_DB_USER:yourPass"
  exit 1;
fi
