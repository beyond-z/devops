#!/bin/bash
source ~/.env

if aws --version 2> /dev/null; then
  aws s3 sync $PORTAL_S3_PROD_FILES_BUCKET $PORTAL_S3_STAGING_FILES_BUCKET

  # This command would delete all files on staging that are not on production.
  #aws s3 sync $PORTAL_S3_PROD_FILES_BUCKET $PORTAL_S3_STAGING_FILES_BUCKET --delete
else
  # Install AWS CLI if it's not there
  echo "Error: Please install 'aws'. E.g."
  echo "  $ sudo easy_install awscli"
  echo "OR"
  echo "  $ curl \"https://s3.amazonaws.com/aws-cli/awscli-bundle.zip\" -o \"awscli-bundle.zip\""
  echo "  $ unzip awscli-bundle.zip"
  echo "  $ sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws"
  echo ""
  echo "You must run 'aws configure' after to setup permissions."
  exit 1;
fi
