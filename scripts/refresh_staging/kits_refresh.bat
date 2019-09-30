#/bin/bash
source ~/.env

now=$(date +"%Y%m%d")
staging_db_dump_file=/home/braven-admin/dumps/kits_staging_db_dump_$now.sql
staging_attendance_db_dump_file=/home/braven-admin/dumps/kits_staging_attendance_db_dump_$now.sql
staging_db_backup_dump_file=/home/braven-admin/dumps/kits_staging_db_backup_dump_$now.sql

echo "Dumping Kits production database and migrating it to a staging database"
echo "mysqldump -h $KITS_PROD_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_PROD_DB_PASSWORD $KITS_PROD_DB_NAME"
mysqldump -h $KITS_PROD_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_PROD_DB_PASSWORD $KITS_PROD_DB_NAME  | sed -e "
  s/https:\/\/kits.bebraven.org/https:\/\/stagingkits.bebraven.org/g;
  s/sso.bebraven.org/stagingsso.bebraven.org/g;
" > $staging_db_dump_file
if [ -e $staging_db_dump_file ]
then
  echo "Finished creating staging database from production."
else
  echo "Failed creating staging database from production."
  echo ""
  echo "If the connection fails, check that the mysql login credentials are correct. Then check that the firewall isn't blocking it by running:"
  echo "telnet $KITS_PROD_DB_SERVER 3306"
  echo "To enable connections through the firewall, login to Braven prod and run: ip link show"
  echo "To find your network interface, e.g. eth0. Then type: ufw allow in on eth0 to any port 3306"
  echo "Then make sure mysql is listening on the public interface, not just localhost, but opening: /etc/mysql/mysql.conf.d/mysqld.cnf"
  echo "And commenting out this line: bind-address = 127.0.0.1"
  echo "Finally, restart mysql: service mysql restart"
  echo "Now, make sure the user is setup with proper GRANTS on the mysql server. Go there and login as root and run this:"
 # echo "CREATE USER '$KITS_PROD_DB_USER'@'$ADMIN_SERVER_IP' IDENTIFIED BY '$KITS_PROD_DB_PASSWORD';
 # echo "-- Where, $ADMIN_SERVER_IP is the IP of this Admin server"
 # echo "GRANT SELECT, LOCK TABLES ON \`$KITS_PROD_DB_NAME\`.* TO '$KITS_PROD_DB_USER'@'$ADMIN_SERVER_IP';"
 # echo "GRANT SELECT, LOCK TABLES ON \`$KITS_PROD_ATTENDANCE_DB_NAME\`.* TO '$KITS_PROD_DB_USER'@'$ADMIN_SERVER_IP';"
 # echo "SHOW GRANTS FOR '$KITS_PROD_DB_USER'@'$ADMIN_SERVER_IP';"
  exit 1;
fi

echo "Dumping Kits production attendance and migrating it to a staging database"
mysqldump -h $KITS_PROD_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_PROD_DB_PASSWORD $KITS_PROD_ATTENDANCE_DB_NAME  | sed -e "
  s/https:\/\/kits.bebraven.org/https:\/\/stagingkits.bebraven.org/g;
" > $staging_attendance_db_dump_file
if [ -e $staging_attendance_db_dump_file ]
then
  echo "Finished creating staging attendance database from production."
else
  echo "Failed creating staging attendance database from production."
  echo "Make sure and run all the commands to setup the production attendnace database to allow connections. See script for example."
  exit 1;
fi

echo "Backing up staging database"
echo "mysqldump -h $KITS_STAGING_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_STAGING_DB_PASSWORD $KITS_PROD_DB_NAME > $staging_db_backup_dump_file"
mysqldump -h $KITS_STAGING_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_STAGING_DB_PASSWORD $KITS_PROD_DB_NAME > $staging_db_backup_dump_file
if [ -e $staging_db_backup_dump_file ]
then
  echo "Finished backing up staging database."
else
  echo "Failed backing up staging database."
  echo "Make sure and run all the commands to setup the staging database to allow connections as you did for the production database. See the commands in the script."
  exit 1;
fi

echo "Importing production database for Kits into staging"
echo "mysql -h $KITS_STAGING_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_STAGING_DB_PASSWORD $KITS_PROD_DB_NAME < $staging_db_dump_file"
mysql -h $KITS_STAGING_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_STAGING_DB_PASSWORD $KITS_PROD_DB_NAME < $staging_db_dump_file
if [ $? -ne 0 ]
then
  echo "Failed importing production database into staging."
  echo "Make sure the commands where run to create the $KITS_PROD_DB_USER on staging and that they were granted the proper permissions"
  echo "e.g. GRANT ALL PRIVILEGES ON \`$KITS_PROD_DB_NAME\`.* TO '$KITS_PROD_DB_USER'@'$ADMIN_SERVER_IP';"
  exit 1;
fi

 echo "Importing production database for Kits attendance tracking into staging"
mysql -h $KITS_STAGING_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_STAGING_DB_PASSWORD $KITS_PROD_ATTENDANCE_DB_NAME < $staging_attendance_db_dump_file
if [ $? -ne 0 ]
then
  echo "Failed importing production attendance database into staging."
  echo "Make sure the commands where run to create the $KITS_PROD_DB_USER on staging and that they were granted the proper permissions"
  echo "e.g. GRANT ALL PRIVILEGES ON \`$KITS_PROD_ATTENDANCE_DB_NAME\`.* TO '$KITS_PROD_DB_USER'@'$ADMIN_SERVER_IP';"
  exit 1;
fi

echo "Creating dev database for Kits from staging database"
./kits_create_dev_db.bat $staging_db_dump_file
if [ $? -ne 0 ]
then
  echo "Failed creating dev database for Kits from staging database"
  exit 1;
fi

echo "Creating dev database for Kits attendance from staging database"
./kits_create_dev_attendance_db.bat $staging_attendance_db_dump_file
if [ $? -ne 0 ]
then
  echo "Failed creating dev database for Kits attendance from staging database"
  exit 1;
fi

echo "Transferring content from Kits production to staging"
braven_content_local_folder=~/src/kits/wp-content
braven_content_remote_folder=/var/www/html/wp-content
rsync -avz $KITS_PROD_USER:$braven_content_remote_folder/uploads/ $braven_content_local_folder/uploads
if [ $? -ne 0 ]
then
  echo "Failed pulling uploads folder from production to admin server using:"
  echo "rsync -avz $KITS_PROD_USER:$braven_content_remote_folder/uploads/ $braven_content_local_folder/uploads"
  exit 1;
fi

rsync -avz $braven_content_local_folder/uploads/ $KITS_STAGING_USER:$braven_content_remote_folder/uploads
if [ $? -ne 0 ]
then
  echo "Failed pushing uploads folder from admin server to staging using:"
  echo "rsync -avz $braven_content_local_folder/uploads/ $KITS_STAGING_USER:$braven_content_remote_folder/uploads"
  exit 1;
fi

#TODO: use the kits_refresh_dev_files.bat script
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

rsync -avz $braven_content_local_folder/plugins/ $KITS_STAGING_USER:$braven_content_remote_folder/plugins
if [ $? -ne 0 ]
then
  echo "Failed pushing plugins folder from admin server to staging using:"
  echo "rsync -avz $braven_content_local_folder/plugins/ $KITS_STAGING_USER:$braven_content_remote_folder/plugins"
  exit 1;
fi

#TODO: use the kits_refresh_dev_files.bat script
echo "Transferring plugins content from Kits production to kits-dev-files S3 bucket"
aws s3 sync $braven_content_local_folder/plugins/ 's3://kits-dev-files/plugins/'
if [ $? -ne 0 ]
then
  echo "Failed pushing plugins folder from admin server to kits-dev-files S3 bucket using:"
  echo "aws s3 sync $braven_content_local_folder/plugins/ s3://kits-dev-files/plugins/"
  exit 1;
fi

echo "Restarting Braven staging server"
ssh $KITS_STAGING_USER 'cd /var/www/html; git pull origin staging; chown -R www-data:www-data .; /etc/init.d/apache2 restart'
