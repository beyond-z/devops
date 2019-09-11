#!/bin/bash
if [ -z "$1" ]
then
  echo "Please pass in the staging DB file to use. E.g.: ./lms_create_dev_db.bat ~/dumps/lms_staging_db_dump_20190909.sql"
  exit 1
fi

source ~/.env

now=$(date +"%Y%m%d")
db_dump_staging_file=$1
db_dump_dev_file=~/dumps/lms_dev_db_dump_$now.sql
db_dump_dev_file_gz=${db_dump_dev_file}.gz

# Turn it into a development worth DB, compress and add to S3 so that local dev environments can pull it.
# TODO: figure out how to drop old content from the versions table. It's massive. We don't need the old stuff in the dev env.
echo "Migrating Canvas staging database to dev database"
cat $db_dump_staging_file | sed -e "
  # Replace staging access token with a dev one.
  $PORTAL_REPLACE_STAGING_ACCESS_TOKEN_WITH_DEV_REGEX
  # this is the access token hint
  $PORTAL_REPLACE_STAGING_ACCESS_TOKEN_HINT_WITH_DEV_REGEX

  # SSO config
  s/https:\/\/stagingsso.bebraven.org/http:\/\/ssoweb:3002/g;
  # Main site
  s/https:\/\/stagingjoin.bebraven.org/http:\/\/joinweb:3001/g;
  # Also fix up internal links in assignments to stay on staging as we navigate
  s/https:\/\/stagingportal.bebraven.org/http:\/\/canvasweb:3000/g;
  # Braven help - note we dont have a staging version of this server, but if we create one it will start working and we want to avoid staging editing the production site
  s/https:\/\/staginghelp.bebraven.org/http:\/\/helpweb/g;
  # Also fix up links to custom CSS/JS
  s/https:\/\/s3.amazonaws.com\/canvas-stag-assets/http:\/\/cssjsweb:3004/g;
" | gzip > $db_dump_dev_file_gz

if [ $? -ne 0 ]
then
  echo "Failed converting $db_dump_staging_file to a dev DB at $db_dump_dev_file_gz"
  exit 1;
fi


# Put the dev DBs on S3 so they can be pulled by local devs onto their machine.
# Store a history of snapshots, but always overwrite the latest b/c that's what devs will pull.
if aws --version 2> /dev/null; then
  aws s3 cp $db_dump_dev_file_gz 's3://canvas-dev-db-dumps/lms_dev_db_dump_latest.sql.gz'
  aws s3 cp $db_dump_dev_file_gz "s3://canvas-dev-db-dumps/snapshots/lms_dev_db_dump_$now.sql.gz"
  if [ $? -ne 0 ]
  then
    echo "Failed transfering Canvas dev DB: $db_dump_dev_file_gz to the s3://canvas-dev-db-dumps bucket."
    exit 1;
  fi
  # Don't store these locally b/c they will fill up the disk. Store on S3 only.
  rm $db_dump_dev_file_gz
else
  # Install AWS CLI if it's not there
  echo "Error: Please install 'aws'. E.g."
  echo "   $ pip3 install awscli --upgrade --user"
  echo "OR"
  echo "  $ sudo easy_install awscli"
  echo "OR"
  echo "  $ curl \"https://s3.amazonaws.com/aws-cli/awscli-bundle.zip\" -o \"awscli-bundle.zip\""
  echo "  $ unzip awscli-bundle.zip"
  echo "  $ sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws"
  echo ""
  echo "You must run 'aws configure' after to setup permissions."
  exit 1;
fi
