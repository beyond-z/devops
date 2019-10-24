#!/bin/bash
if [ -z "$1" ]
then
  echo "Please pass in the staging DB filename to store the created DB in. E.g.: ./lms_create_staging_db.bat ~/dumps/lms_staging_db_dump_20190909.sql"
  exit 1
fi

source ~/.env

# TODO: this creates a HUGE file to send across the wire.  Tons of it is in the error_reports, messages, and versions tables alone.
# Maybe I can clear the main values in those columns in those tables when i transfer?

db_dump_staging_file=$1

echo "Dumping Canvas production database and migrating it to a staging database"

# Remove s3:// prefix since we're targeting a URL like: https://s3.amazonaws.com/<bucket_name>/<file_name>
escaped_prod_bucket=${PORTAL_S3_PROD_BUCKET//s3:\/\/}
escaped_staging_bucket=${PORTAL_S3_STAGING_BUCKET//s3:\/\/}

# This would just escape / with \/ but we need to remove the s3:// prefix in this case
#escaped_prod_bucket=${PORTAL_S3_PROD_BUCKET//\//\\/}
#escaped_staging_bucket=${PORTAL_S3_STAGING_BUCKET//\//\\/}

pg_dump --clean -h $PORTAL_PROD_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d $PORTAL_PROD_DB_NAME | sed -e "
  # Replace production access token with staging token. Encrypted values
  # gotten from the two current dumps and just replaced here.
  $PORTAL_REPLACE_PROD_ACCESS_TOKEN_WITH_STAGING_REGEX
  # this is the access token hint
  $PORTAL_REPLACE_PROD_ACCESS_TOKEN_HINT_WITH_STAGING_REGEX

  # SSO config
  s/sso.bebraven.org/stagingsso.bebraven.org/g;
  # Main site
  s/join.bebraven.org/stagingjoin.bebraven.org/g;
  # Also fix up internal links in assignments to stay on staging as we navigate
  s/portal.bebraven.org/stagingportal.bebraven.org/g;
  # Braven help - note we dont have a staging version of this server, but if we create one it will start working and we want to avoid staging editing the production site 
  s/help.bebraven.org/staginghelp.bebraven.org/g;

  # CSS/JS config 
  s/$escaped_prod_bucket/$escaped_staging_bucket/g;

  # BTW Passwords are done via SSO so we dont have to try to change them here
" > $db_dump_staging_file

if [ $? -ne 0 ]
then
  echo "Failed creating Canvas staging database from production."
  echo ""
  echo "Double check that you have a ~/.pgpass file with credentials to connect to the staging and prod databases. Note that the ~/.pgpass file should have permissions set to chmod 600.  Example of file contents:"
  echo "$PORTAL_STAGING_DB_SERVER:5432:*:$PORTAL_PROD_DB_USER:yourPass"
  echo "$PORTAL_PROD_DB_SERVER:5432:*:$PORTAL_PROD_DB_USER:yourPass"
  exit 1;
fi
