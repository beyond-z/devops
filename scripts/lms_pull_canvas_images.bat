#!/bin/bash
source ~/.env

if aws --version 2> /dev/null; then
  now=$(date +"%Y-%m-%d") 
  backup_dir=~/backups/canvas_images_$now
  echo "Backing up Canvas images to: $backup_dir"
  mkdir $backup_dir
  aws s3 sync $PORTAL_S3_PROD_FILES_BUCKET $backup_dir
  tar -zcvf ${backup_dir}.tar.gz $backup_dir
  rm -rf $backup_dir
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
