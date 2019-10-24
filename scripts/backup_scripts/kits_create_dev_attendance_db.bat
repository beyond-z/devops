#!/bin/bash
if [ -z "$1" ]
then
  echo "Please pass in the staging attendance DB file to use. E.g.: ./kits_create_dev_attendance_db.bat ~/dumps/kits_staging_attendance_db_dump_20190909.sql"
  exit 1
fi

source ~/.env

now=$(date +"%Y%m%d")
db_dump_staging_file=$1
db_dump_dev_file=~/dumps/kits_dev_attendance_db_dump_$now.sql
db_dump_dev_file_gz=${db_dump_dev_file}.gz

# Turn it into a development worth DB, compress and add to S3 so that local dev environments can pull it.
echo "Migrating Kits staging attendance database to dev database"
cat $db_dump_staging_file | sed -e "

  s/https:\/\/stagingkits.bebraven.org/http:\/\/kitsweb:3005/g;

" | gzip > $db_dump_dev_file_gz

if [ $? -ne 0 ]
then
  echo "Failed converting $db_dump_staging_file to a dev DB at $db_dump_dev_file_gz"
  exit 1;
fi


# Put the dev DBs on S3 so they can be pulled by local devs onto their machine.
# Store a history of snapshots, but always overwrite the latest b/c that's what devs will pull.
if aws --version 2> /dev/null; then
  aws s3 cp $db_dump_dev_file_gz 's3://kits-dev-db-dumps/kits_dev_attendance_db_dump_latest.sql.gz'
  aws s3 cp $db_dump_dev_file_gz "s3://kits-dev-db-dumps/snapshots/kits_dev_attendance_db_dump_$now.sql.gz"
  if [ $? -ne 0 ]
  then
    echo "Failed transfering Kits dev DB: $db_dump_dev_file_gz to the s3://kits-dev-db-dumps bucket."
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
