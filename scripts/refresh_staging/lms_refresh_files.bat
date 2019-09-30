#!/bin/bash
source ~/.env

if aws --version 2> /dev/null; then
  aws s3 sync $PORTAL_S3_PROD_FILES_BUCKET $PORTAL_S3_STAGING_FILES_BUCKET
  aws s3 sync $PORTAL_S3_STAGING_FILES_BUCKET $PORTAL_S3_DEV_FILES_BUCKET

  # This command would delete all files on staging that are not on production.
  #aws s3 sync $PORTAL_S3_PROD_FILES_BUCKET $PORTAL_S3_STAGING_FILES_BUCKET --delete
else
  # Install AWS CLI if it's not there
  echo "Error: Please install 'aws'. E.g."
  echo "   $ pip3 install awscli"
  echo ""
  echo "You must run 'aws configure' after to setup permissions. Enter your IAM Access Token and Secret. Use us-west-1 for the region."
  exit 1;
fi
