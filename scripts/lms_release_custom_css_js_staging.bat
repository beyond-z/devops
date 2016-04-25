#!/bin/bash
source ~/.env

if aws --version 2> /dev/null; then
  cd ~/src/canvas-js-css
  git checkout staging
  git pull origin staging
  if [ $? -ne 0 ]
  then
    echo "Failed pulling updated staging assets from git."
    exit 1
  fi

  aws s3 sync . $PORTAL_S3_STAGING_BUCKET --exclude ".git/*" --exclude "README.md" --cache-control "public, max-age=31536000"
  if [ $? -ne 0 ]
  then
    echo "Failed pushing staging assets to Amazon S3 bucket"
    exit 1
  fi

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
