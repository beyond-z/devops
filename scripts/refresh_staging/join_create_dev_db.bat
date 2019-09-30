#!/bin/bash
source ~/.env

cd ~/src/join/

echo "Taking staging db dump to create dev db and pushing it to the join-dev-db-dumps S3 bucket for the developement env to access"

now=$(date +"%Y%m%d")
db_dump_dev_file=~/dumps/join_dev_db_dump_$now.sql
db_dump_dev_file_gz=${db_dump_dev_file}.gz

heroku pg:backups capture --remote staging

# TODO: we don't really have to do any of this. We can just have devs pull directly from staging using heroku capture, pull and then run DB commands
# such as the one found in join_refresh to change all passwords to the test one.
# It's prob still a good idea to store nightly backups in S3, but we're overcomplicating things.
# It's much more scalable to alter the DB, using the DB, rather than piping it through sed.
# On the other hand, maybe we stick with this to be consistent for now since this is how the Portal DB's are gotten.
# When we have devs pull from the staging DBs directly, we should do it everywhere consistently.. Talk to the other devs and get their inpu.
# See: https://devcenter.heroku.com/articles/heroku-postgres-import-export

echo "Migrating Join staging database to Join dev database"
curl `heroku pg:backups public-url --app $HEROKU_STAGING_APP` | 
cat $db_dump_staging_file | sed -e "
  # TODO: Replace any staging specify values, like access tokens, with dev ones using regexes. See the lms_create_dev_db.bat script for an example.
" | gzip > $db_dump_dev_file_gz

if [ $? -ne 0 ]
then
  echo "Failed downloading and converting to a dev DB dump the file: $db_dump_dev_file_gz"
  exit 1;
fi

# Put the dev DBs on S3 so they can be pulled by local devs onto their machine.
# Store a history of snapshots, but always overwrite the latest b/c that's what devs will pull.
if aws --version 2> /dev/null; then
  aws s3 cp $db_dump_dev_file_gz 's3://join-dev-db-dumps/join_dev_db_dump_latest.sql.gz'
  aws s3 cp $db_dump_dev_file_gz "s3://join-dev-db-dumps/snapshots/join_dev_db_dump_$now.sql.gz"
  if [ $? -ne 0 ]
  then
    echo "Failed transfering Join dev DB: $db_dump_dev_file_gz to the s3://join-dev-db-dumps bucket."
    exit 1;
  fi
  # Don't store these locally b/c they will fill up the disk. Store on S3 only.
  rm $db_dump_dev_file_gz
else
  # Install AWS CLI if it's not there
  echo "Error: Please install 'aws'. E.g."
  echo "   $ pip3 install awscli"
  echo ""
  echo "You must run 'aws configure' after to setup permissions. Enter your IAM Access Token and Secret. Use us-west-1 for the region."
  exit 1;
fi
