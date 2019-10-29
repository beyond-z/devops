#!/bin/bash
source ~/.env

echo "Copying canvas_production_queue schema from production to staging"
now=$(date +"%Y%m%d")
db_dump_staging_file=~/dumps/lms_staging_db_dump_queue_$now.sql

pg_dump --clean -s -h $PORTAL_PROD_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d canvas_queue_production > $db_dump_staging_file && psql -h $PORTAL_STAGING_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d canvas_queue_production -f $db_dump_staging_file

if [ $? -ne 0 ]
then
  echo "Failed transfering Canvas Queue database from production to staging."
  echo ""
  echo "Double check that you have a ~/.pgpass file with credentials to connect to the staging and prod databases. Note that the ~/.pgpass file should have permissions set to chmod 600.  Example of file contents:"
  echo "$PORTAL_STAGING_DB_SERVER:5432:*:$PORTAL_PROD_DB_USER:yourPass"
  echo "$PORTAL_PROD_DB_SERVER:5432:*:$PORTAL_PROD_DB_USER:yourPass"
  exit 1;
fi
