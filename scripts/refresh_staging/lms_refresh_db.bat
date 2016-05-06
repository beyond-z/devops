#!/bin/bash
source ~/.env

# TODO: this creates a 112 MB file to send across the wire.  45 MB are in the error_reports, messages, and versions tables alone.
# Maybe I can clear the main values in those columns in those tables when i transfer?

now=$(date +"%Y%m%d")
db_dump_staging_file=~/dumps/lms_staging_db_dump_$now.sql
db_dump_dev_file=~/dumps/lms_dev_db_dump_$now.sql

mv ~/dumps/lms_*.sql.gz ~/dumps/~archive || { echo >&2 " ---- The previous warning most likely just means there were no old backups to archive"; }

echo "Migrating Canvas production database to staging"

# Remove s3:// prefix since we're targeting a URL like: https://s3.amazonaws.com/<bucket_name>/<file_name>
escaped_prod_bucket=${PORTAL_S3_PROD_BUCKET//s3:\/\/}
escaped_staging_bucket=${PORTAL_S3_STAGING_BUCKET//s3:\/\/}

# This would just escape / with \/ but we need to remove the s3:// prefix in this case
#escaped_prod_bucket=${PORTAL_S3_PROD_BUCKET//\//\\/}
#escaped_staging_bucket=${PORTAL_S3_STAGING_BUCKET//\//\\/}

pg_dump --clean -h $PORTAL_PROD_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d $PORTAL_PROD_DB_NAME | sed -e "
  # Replace production access token with staging token. Encrypted values
  # gotten from the two current dumps and just replaced here.
  $PORTAL_REPLACE_PROD_ACCESS_TOKEN_REGEX
  # this is the access token hint
  $PORTAL_REPLACE_PROD_ACCESS_TOKEN_HINT_REGEX

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
" > $db_dump_staging_file && psql -h $PORTAL_STAGING_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d $PORTAL_PROD_DB_NAME -f $db_dump_staging_file

if [ $? -ne 0 ]
then
  echo "Failed transfering Canvas database from production to staging."
  echo ""
  echo "Double check that you have a ~/.pgpass file with credentials to connect to the staging and prod databases. Note that the ~/.pgpass file should have permissions set to chmod 600.  Example of file contents:"
  echo "$PORTAL_STAGING_DB_SERVER:5432:*:$PORTAL_PROD_DB_USER:yourPass"
  echo "$PORTAL_PROD_DB_SERVER:5432:*:$PORTAL_PROD_DB_USER:yourPass"
  exit 1;
fi

# Turn it into a development worth DB, compress and add to S3 so that local dev environments can pull it.
echo "Migrating Canvas staging database to dev database"
cat $db_dump_staging_file | sed -e "
  # Replace staging access token with a dev one.
  $PORTAL_REPLACE_STAGING_ACCESS_TOKEN_REGEX
  # this is the access token hint
  $PORTAL_REPLACE_STAGING_ACCESS_TOKEN_HINT_REGEX

  # SSO config
  s/https:\/\/stagingsso.bebraven.org/http:\/\/sso.docker/g;
  # Main site
  s/https:\/\/stagingjoin.bebraven.org/http:\/\/join.docker/g;
  # Also fix up internal links in assignments to stay on staging as we navigate
  s/https:\/\/stagingportal.bebraven.org/http:\/\/canvas.docker/g;
  # Braven help - note we dont have a staging version of this server, but if we create one it will start working and we want to avoid staging editing the production site
  s/https:\/\/staginghelp.bebraven.org/http:\/\/help.docker/g;
  # Also fix up links to custom CSS/JS
  s/https:\/\/s3.amazonaws.com\/canvas-stag-assets/http:\/\/cssjs.docker/g;
" | gzip > ${db_dump_dev_file}.gz

rm $db_dump_staging_file

