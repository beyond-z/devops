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

  # TODO: doesn't work.  The updated value shows up in the UI, but it doesn't take effect.  
  # Maybe the settings are only read from the DB on server load.  I tried rebooting the server and it didn't work either....
  # Commenting out for now.

  #echo "Updating Custom CSS/JS settings on staging to invalidate browser cache"
  ## The below sed find/replace updates the version query string in the settings for both bz_custom.js and bz_custom.css
  #now=$(date +"%Y%m%d_%H%M")
  #current_settings=`psql -h $PORTAL_STAGING_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -d $PORTAL_PROD_DB_NAME -w -t -A -c "select settings from accounts where id = 1;"`
  #echo "update accounts set settings = '$current_settings' where id = 1" | sed -e "s/bz_custom\.js?v=[_0-9]*/bz_custom.js?v=$now/g;s/bz_custom\.css?v=[_0-9]*/bz_custom.css?v=$now/g;" | psql -h $PORTAL_STAGING_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -d $PORTAL_PROD_DB_NAME -w
  
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
