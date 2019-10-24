#/bin/bash
source ~/.env

echo "Transferring content from Kits production to s3://kits-dev-files bucket"
braven_content_local_folder=~/src/kits/wp-content
braven_content_remote_folder=/var/www/html/wp-content
rsync -avz $KITS_PROD_USER:$braven_content_remote_folder/uploads/ $braven_content_local_folder/uploads
if [ $? -ne 0 ]
then
  echo "Failed pulling uploads folder from production to admin server using:"
  echo "rsync -avz $KITS_PROD_USER:$braven_content_remote_folder/uploads/ $braven_content_local_folder/uploads"
  exit 1;
fi

echo "Transferring uploads content from Kits production to kits-dev-files S3 bucket"
if aws --version 2> /dev/null; then
  # Note: not using gzip b/c this is additive and once you have the baseline set of uploads, then each subsequent
  # run just syncs to changes
  aws s3 sync $braven_content_local_folder/uploads/ 's3://kits-dev-files/uploads/'
  if [ $? -ne 0 ]
  then
    echo "Failed pushing uploads folder from admin server to kits-dev-files S3 bucket using:"
    echo "aws s3 sync $braven_content_local_folder/uploads/ s3://kits-dev-files/uploads/"
    exit 1;
  fi
else
  # Install AWS CLI if it's not there
  echo "Error: Please install 'aws'. E.g."
  echo "   $ pip3 install awscli"
  echo ""
  echo "You must run 'aws configure' after to setup permissions. Enter your IAM Access Token and Secret. Use us-west-1 for the region."
  exit 1;
fi

rsync -avz $KITS_PROD_USER:$braven_content_remote_folder/plugins/ $braven_content_local_folder/plugins
if [ $? -ne 0 ]
then
  echo "Failed pulling plugins folder from production to admin server using:"
  echo "rsync -avz $KITS_PROD_USER:$braven_content_remote_folder/plugins/ $braven_content_local_folder/plugins"
  exit 1;
fi

echo "Transferring plugins content from Kits production to kits-dev-files S3 bucket"
aws s3 sync $braven_content_local_folder/plugins/ 's3://kits-dev-files/plugins/'
if [ $? -ne 0 ]
then
  echo "Failed pushing plugins folder from admin server to kits-dev-files S3 bucket using:"
  echo "aws s3 sync $braven_content_local_folder/plugins/ s3://kits-dev-files/plugins/"
  exit 1;
fi

