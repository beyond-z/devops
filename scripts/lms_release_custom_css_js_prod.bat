#!/bin/bash
source ~/.env

read -r -p "Are you sure you want to release staging custom CSS/JS to production? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then


if aws --version 2> /dev/null; then
  cd ~/src/canvas-js-css
  # Merge the code from staging to master
  git checkout staging; git pull origin staging; git checkout master; git pull origin master; git merge --no-ff staging
  if [ $? -ne 0 ]
  then
    echo "Failed merging staging to master"
    exit 1;
  fi
  
  now=$(date +"%Y-%m-%d.%H%M")
  read -r -p $'Please type the message for the tag of the branch you\'re releasing. >>>> \n' tagcommand
  tagname=bv-release/$now
  echo "git tag -a $tagname -m \"$tagcommand\""
  git tag -a $tagname -m "$tagcommand"
  
  if [ $? -ne 0 ]
  then
    echo "Failed tagging master"
    exit 1;
  fi
  
  git push origin $tagname
  
  # Push the new master branch to github.
  git push origin master
  if [ $? -ne 0 ]
  then
    echo "Failed pushing code to master"
    exit 1;
  fi

  aws s3 sync . $PORTAL_S3_PROD_BUCKET --exclude ".git/*" --exclude "README.md" --cache-control "public, max-age=31536000"
  if [ $? -ne 0 ]
  then
    echo "Failed pushing production assets to Amazon S3 bucket"
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

else
  echo "Aborted!"
fi
