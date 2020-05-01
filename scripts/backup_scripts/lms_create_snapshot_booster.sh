#!/bin/bash
source ~/scripts/helper_functions.sh
if [ -z "$1" ]
then
  echo "Please pass in the staging DB filename to store the created gzipped DB in. E.g.:"
  echo "./lms_create_booster_snapshot.sh ~/dumps/lms_staging_db_20191024.sql.gz"
  exit 1
fi

# TODO: this creates a HUGE file to send across the wire.  Tons of it is in the error_reports, messages, and versions tables alone.
# Maybe I can clear the main values in those columns in those tables when i transfer?

dump_file=$1
prod_dump_file=${dump_file}.prod.dump

echo "### Snapshotting the Booster Canvas production database and migrating it to a staging database"

echo "Preparing for download of snapshot"
heroku pg:backups capture --app $PORTAL_BOOSTER_PROD_APP \
  || { echo >&2 "Error: command 'heroku pg:backups capture --app $PORTAL_BOOSTER_PROD_APP' failed."; exit 1; }
# Note: this is in pg_restore compressed format.
echo "Downloading snapshot to $dump_file"
heroku pg:backups:download -o $prod_dump_file --app $PORTAL_BOOSTER_PROD_APP \
  || { echo >&2 "Error: command 'heroku pg:backups:download -o $dump_file --app $PORTAL_BOOSTER_PROD_APP' failed."; exit 1; }

## Remove s3:// prefix since we're targeting a URL like: https://s3.amazonaws.com/<bucket_name>/<file_name>
escaped_prod_bucket=${PORTAL_BOOSTER_S3_PROD_BUCKET//s3:\/\/}
escaped_staging_bucket=${PORTAL_BOOSTER_S3_STAGING_BUCKET//s3:\/\/}

# Turns compressed DB into plain sql, pipes that to sed to do some regex replaces, 
# then creates a plain old gzip of the sql commands.
pg_restore $prod_dump_file | sed -e "
  # Replace production access token with staging token. Encrypted values
  # gotten from the two current dumps and just replaced here.
  $PORTAL_BOOSTER_REPLACE_PROD_ACCESS_TOKEN_WITH_STAGING_REGEX
  # this is the access token hint
  $PORTAL_BOOSTER_REPLACE_PROD_ACCESS_TOKEN_HINT_WITH_STAGING_REGEX

  # New SSO config / platform
  s/platform.bebraven.org/stagingplatform.bebraven.org/g;
  # Main site
  s/join.bebraven.org/stagingjoin.bebraven.org/g;
  # Also fix up internal links in assignments to stay on staging as we navigate
  s/booster.braven.org/stagingbooster.braven.org/g;

  # CSS/JS config 
  s/$escaped_prod_bucket/$escaped_staging_bucket/g;

  # BTW Passwords are done via SSO so we dont have to try to change them here
" | gzip > $dump_file

if [ $? -ne 0 ]
then
  echo "Failed creating Booster Canvas staging database from production."
  exit 1;
fi

rm $prod_dump_file

echo "### Done: Snapshotting the Booster Canvas production database and migrating it to a staging database"

