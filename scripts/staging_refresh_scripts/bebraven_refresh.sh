#!/bin/bash
source ~/scripts/helper_functions.sh

################
# This script loads the latest BeBraven.org Wordpres and Mock Iterviewer DB snapshots from $BRAVEN_S3_STAGING_DBS_BUCKET
# into the staging server DB. It also syncs the wp-content files to be the latest ones from prod
# stored on $BRAVEN_S3_STAGING_WP_CONTENT_BUCKET
################

exit_if_no_aws

echo "### Restoring BeBraven.org staging DB from $bebraven_latest_dump_s3_path"
aws s3 cp $bebraven_latest_dump_s3_path - | gunzip |  mysql -h $BRAVEN_STAGING_DB_SERVER -P 3306 -u $BRAVEN_PROD_DB_USER -p$BRAVEN_STAGING_DB_PASSWORD $BRAVEN_PROD_DB_NAME
if [ $? -ne 0 ]
then
  echo "Error: Failed restoring from $bebraven_latest_dump_s3_path database"; 
  echo "Make sure the commands were run to create the $BRAVEN_PROD_DB_USER on staging and that they were granted the proper permissions"
  echo "e.g. GRANT ALL PRIVILEGES ON \`$BRAVEN_PROD_DB_NAME\`.* TO '$BRAVEN_PROD_DB_USER'@'$ADMIN_SERVER_IP';"  
  exit 1; 
fi
echo "### Done: Restoring BeBraven.org staging DB from $bebraven_latest_dump_s3_path"

echo "### Restoring BeBraven.org staging Mock IV DB from $braven_latest_dump_mock_iv_s3_path"
aws s3 cp $braven_latest_dump_mock_iv_s3_path - | gunzip | mysql -h $BRAVEN_STAGING_DB_SERVER -P 3306 -u $BRAVEN_PROD_DB_USER -p$BRAVEN_STAGING_DB_PASSWORD $BRAVEN_PROD_INTERVIEW_MATCHER_DB_NAME
if [ $? -ne 0 ]
then
  echo "Error: Failed restoring from $braven_latest_dump_mock_iv_s3_path database"; 
  echo "Make sure the commands where run to create the $BRAVEN_PROD_DB_USER on staging and that they were granted the proper permissions"
  echo "e.g. GRANT ALL PRIVILEGES ON \`$BRAVEN_PROD_INTERVIEW_MATCHER_DB_NAME\`.* TO '$BRAVEN_PROD_DB_USER'@'$ADMIN_SERVER_IP';"
  exit 1;
fi
echo "### Done: Restoring BeBraven.org staging Mock IV DB from $braven_latest_dump_mock_iv_s3_path"

echo "### Updating the uploads and plugins wp-content on BeBraven.org staging to match prod"
bebraven_local_wp_content_folder=~/src/braven_2/wp-content

#Note: we sync the $BRAVEN_S3_STAGING_WP_CONTENT_BUCKET stuff to the local dir as part of the nightly backup, so 

# Note: not using gzip b/c this is additive and once you have the baseline set of uploads, then each subsequent
# run just syncs to changes
rsync -avz $bebraven_local_wp_content_folder/uploads/ $BRAVEN_STAGING_USER:$BRAVEN_PROD_WP_CONTENT_FOLDER/uploads \
  || { echo >&2 "Error: Failed running 'rsync -avz '$bebraven_local_wp_content_folder/uploads/ $BRAVEN_STAGING_USER:$BRAVEN_PROD_WP_CONTENT_FOLDER/uploads'"; exit 1; }

rsync -avz $bebraven_local_wp_content_folder/plugins/ $BRAVEN_STAGING_USER:$BRAVEN_PROD_WP_CONTENT_FOLDER/plugins \
  || { echo >&2 "Error: Failed running 'rsync -avz '$bebraven_local_wp_content_folder/plugins/ $BRAVEN_STAGING_USER:$BRAVEN_PROD_WP_CONTENT_FOLDER/plugins'"; exit 1; }

echo "### Done: Updating the uploads and plugins wp-content on BeBraven.org staging to match prod"


echo "Restarting BeBraven.org staging server"
ssh $BRAVEN_STAGING_USER 'cd /var/www/html; git pull origin staging; chown -R www-data:www-data .; /etc/init.d/apache2 restart'
