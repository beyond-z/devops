#/bin/bash
source ~/.env

now=$(date +"%Y%m%d")
staging_db_dump_file=/home/braven-admin/dumps/kits_staging_db_dump_$now.sql
staging_attendance_db_dump_file=/home/braven-admin/dumps/kits_staging_attendance_db_dump_$now.sql
staging_db_backup_dump_file=/home/braven-admin/dumps/kits_staging_db_backup_dump_$now.sql

echo "Taking Kits production snapshot / backup"
echo "mysqldump -h $KITS_PROD_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_PROD_DB_PASSWORD $KITS_PROD_DB_NAME"
mysqldump -h $KITS_PROD_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_PROD_DB_PASSWORD $KITS_PROD_DB_NAME  | sed -e "
  # TODO: insert any regexes to replace things as needed. E.g.
  s/https:\/\/kits.bebraven.org/https:\/\/stagingkits.bebraven.org/g;
  s/sso.bebraven.org/stagingsso.bebraven.org/g;
" > $staging_db_dump_file
if [ -e $staging_db_dump_file ]
then
  echo "Finished taking production snapshot / backup"
else
  echo "Failed taking production DB dump of Braven Kits website."
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

mysqldump -h $KITS_PROD_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_PROD_DB_PASSWORD $KITS_PROD_ATTENDANCE_DB_NAME  | sed -e "
  # TODO: insert any regexes to replace things as needed. E.g.
  s/https:\/\/kits.bebraven.org/https:\/\/stagingkits.bebraven.org/g;
" > $staging_attendance_db_dump_file

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
mysql -h $KITS_STAGING_DB_SERVER -P 3306 -u $KITS_PROD_DB_USER -p$KITS_STAGING_DB_PASSWORD $KITS_PROD_ATTENDANCE_DB_NAME < $staging_attendance_db_dump_file

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

echo "Restarting Braven staging server"
ssh $KITS_STAGING_USER 'cd /var/www/html; git pull origin staging; chown -R www-data:www-data .; /etc/init.d/apache2 restart'
