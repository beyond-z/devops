#!/bin/bash
source ~/scripts/helper_functions.sh

################
# This script loads the latest Kits Wordpres and Attendance DB snapshots from $KITS_S3_STAGING_DBS_BUCKET 
# into the staging server DB. It also syncs the wp-content files to be the latest ones from prod
# stored on $KITS_S3_STAGING_WP_CONTENT_BUCKET
################

exit_if_no_aws

echo "### Restoring Kits staging DB from $kits_latest_dump_s3_path"
aws s3 cp $kits_latest_dump_s3_path - | gunzip |  mysql -h $KITS_STAGING_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_STAGING_DB_PASSWORD $KITS_PROD_DB_NAME
if [ $? -ne 0 ]
then
  echo "Error: Failed importing $kits_latest_dump_s3_path database"; 
  echo "Make sure the commands were run to create the $KITS_PROD_DB_USER on staging and that they were granted the proper permissions"
  echo "e.g. GRANT ALL PRIVILEGES ON \`$KITS_PROD_DB_NAME\`.* TO '$KITS_PROD_DB_USER'@'$ADMIN_SERVER_IP';"  
  exit 1; 
fi
echo "### Done: Importing $kits_latest_dump_s3_path database into Kits staging DB"

echo "### Importing $kits_latest_dump_attendance_s3_path database into Kits staging DB"
aws s3 cp $kits_latest_dump_attendance_s3_path - | gunzip | mysql -h $KITS_STAGING_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_STAGING_DB_PASSWORD $KITS_PROD_ATTENDANCE_DB_NAME
if [ $? -ne 0 ]
then
  echo "Error: Failed importing $kits_latest_dump_attendance_s3_path database"; 
  echo "Make sure the commands where run to create the $KITS_PROD_DB_USER on staging and that they were granted the proper permissions"
  echo "e.g. GRANT ALL PRIVILEGES ON \`$KITS_PROD_ATTENDANCE_DB_NAME\`.* TO '$KITS_PROD_DB_USER'@'$ADMIN_SERVER_IP';"
  exit 1;
fi
echo "### Done: Restoring Kits staging DB from $kits_latest_dump_s3_path"

echo "Restarting Kits staging server"
ssh $KITS_STAGING_USER 'cd /var/www/html; git pull origin staging; chown -R www-data:www-data .; /etc/init.d/apache2 restart'
