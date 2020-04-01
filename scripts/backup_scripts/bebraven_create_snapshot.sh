#!/bin/bash
source ~/scripts/helper_functions.sh
if [ $# -ne 2 ]
then
  echo "Please pass the database name and the file to store the snapshot in. E.g.: "
  echo "./bebraven_create_snapshot.sh $BRAVEN_PROD_DB_NAME ~/dumps/bebraven_staging_db_20191023.sql.gz"
  exit 1
fi

database_name=$1
dump_file=$2

# Note: this script is meant to be run twice, once for the main wordpress DB and once
# for the mock interviewer DB.
echo "### Snapshotting the BeBraven Dot Org production '${database_name}' database and migrating it to a staging database"
# TODO: we should also change all the PWs to a dev password, but right now all Wordpress admins will have to use the prod password.
mysqldump -h $BRAVEN_PROD_DB_SERVER -P 3306 -u $BRAVEN_PROD_DB_USER -p$BRAVEN_PROD_DB_PASSWORD $database_name | sed -e "
  s/https:\/\/bebraven.org/https:\/\/staging.bebraven.org/g;
  s/https:\/\/join.bebraven.org/https:\/\/stagingjoin.bebraven.org/g;
" | gzip > $dump_file
if [ ! -f $dump_file ]
then
  echo "Failed creating BeBraven staging database $database_name from production."
  echo ""
  echo "If the connection fails, check that the mysql login credentials are correct. Then check that the firewall isn't blocking it by running:"
  echo "telnet $BRAVEN_PROD_DB_SERVER 3306"
  echo "To enable connections through the firewall, login to Braven prod and run: ip link show"
  echo "To find your network interface, e.g. eth0. Then type: ufw allow in on eth0 to any port 3306"
  echo "Then make sure mysql is listening on the public interface, not just localhost, but opening: /etc/mysql/mysql.conf.d/mysqld.cnf"
  echo "And commenting out this line: bind-address = 127.0.0.1"
  echo "Finally, restart mysql: service mysql restart"
  echo "Now, make sure the user is setup with proper GRANTS on the mysql server. Go there and login as root and run the commands in the script printing this message."
  # TODO: spent too much time trying to escape this properply, so commenting out for now.
 # echo "CREATE USER '$BRAVEN_PROD_DB_USER'@'$ADMIN_SERVER_IP' IDENTIFIED BY '$BRAVEN_PROD_DB_PASSWORD';
 # echo "-- Where, $ADMIN_SERVER_IP is the IP of this Admin server"
 # echo "GRANT SELECT, LOCK TABLES ON \`$BRAVEN_PROD_DB_NAME\`.* TO '$BRAVEN_PROD_DB_USER'@'$ADMIN_SERVER_IP';"
 # echo "GRANT SELECT, LOCK TABLES ON \`$BRAVEN_PROD_MOCK_IV_DB_NAME\`.* TO '$BRAVEN_PROD_DB_USER'@'$ADMIN_SERVER_IP';"
 # echo "SHOW GRANTS FOR '$BRAVEN_PROD_DB_USER'@'$ADMIN_SERVER_IP';"
  exit 1;
fi

echo "### Done: Snapshotting the BeBraven production '${database_name}' database and migrating it to a staging database"
