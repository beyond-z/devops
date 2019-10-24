#!/bin/bash
source ~/.env

now=$(date +"%Y%m%d")
db_dump_staging_file=~/dumps/lms_staging_db_dump_$now.sql
db_dump_dev_file=~/dumps/lms_dev_db_dump_$now.sql

echo "Migrating Canvas production database to staging"

./lms_create_staging_db.bat $db_dump_staging_file
if [ $? -ne 0 ]
then
  exit 1;
fi

echo "Loading staging database into Canvas"
psql -h $PORTAL_STAGING_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d $PORTAL_PROD_DB_NAME -f $db_dump_staging_file
if [ $? -ne 0 ]
then
  echo "Failed loading staging database into Canvas."
  echo ""
  echo "Double check that you have a ~/.pgpass file with credentials to connect to the staging databases. Note that the ~/.pgpass file should have permissions set to chmod 600.  Example of file contents:"
  echo "$PORTAL_STAGING_DB_SERVER:5432:*:$PORTAL_PROD_DB_USER:yourPass"
  exit 1;
fi

# Turn it into a development worth DB, compress and add to S3 so that local dev environments can pull it.
./lms_create_dev_db.bat $db_dump_staging_file
if [ $? -ne 0 ]
then
  echo "Failed creating a dev DB from the staging DB: $$db_dump_staging_file"
fi

# If we want to save snapshots of the staging DBs, we should do it on S3. Saving them here will blow up the disk space
# once we have a daily or weekly refresh running.
rm $db_dump_staging_file
