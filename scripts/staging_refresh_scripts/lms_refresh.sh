#!/bin/bash
source ~/scripts/helper_functions.sh

################
# This script loads the latest Portal snapshots from $PORTAL_S3_STAGING_DBS_BUCKET 
# into the staging server DB.
################

# TODO: REPLACE THIS WHOLE SCRIPT (in fact, replace the whole infratructure for LMS DBs)
# to use RDS snapshots. A staging DB refresh shoiuld really just be choosing an RDS snapshot and restoring it,
# then running some scripts to make it work in staging (aka get rid of sed)
# This will save a TON of space, b/c snapshots act as full backups but the data
# is stored incrementally.
# See: https://app.asana.com/0/inbox/9489675646629/1145575802065481/1146474823629330
# Leaning towards not doing this now. Just keep storing in S3.

exit_if_no_aws

echo "### Importing $lms_latest_dump_s3_path database into Portal staging DB"
aws s3 cp $lms_latest_dump_s3_path - | gunzip | psql -h $PORTAL_STAGING_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d $PORTAL_PROD_DB_NAME 
if [ $? -ne 0 ]
then
  echo "Error: Failed importing $kits_latest_dump_s3_path database"; 
  echo "Double check that you have a ~/.pgpass file with credentials to connect to the staging databases."
  echo "Note that the ~/.pgpass file should have permissions set to chmod 600.  Example of file contents:"
  echo "$PORTAL_STAGING_DB_SERVER:5432:*:$PORTAL_PROD_DB_USER:yourPass"
  exit 1; 
fi

echo "### Done: Importing $lms_latest_dump_s3_path database into Portal staging DB"
