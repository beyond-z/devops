#/bin/bash
source ~/.env

cd ~/src/braven
git checkout staging; git pull origin staging; 

if [ $? -ne 0 ]
then
  echo "Failed pulling staging"
  exit 1;
fi

ssh $BRAVEN_STAGING_USER 'cd /var/www; git pull origin staging; chown -R www-data:www-data .; /etc/init.d/apache2 restart'
if [ $? -ne 0 ]
then
  echo "Failed connected to staging server and updating code"
  exit 1;
fi

# TODO: refresh staging from production?  Right now, we have to do this manually using the updraftplus plugin.
