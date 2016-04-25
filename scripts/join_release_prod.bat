#/bin/bash

# IMPORTANT, if there were changes to the db/seeds.rb file they won't be added to production using this script.  

read -r -p "Are you sure you want to release staging to production? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

cd ~/src/join/

# update the ENV config on prod 
cp .env-prod .env
heroku config:push --overwrite --remote production

# Merge the code from staging to master
git checkout staging; git pull; git checkout master; git pull; git merge --no-ff staging

if [ $? -ne 0 ]
then
  echo "Failed merging staging to master"
  exit 1;
fi

now=$(date +"%Y%m%d_%H%M")
read -r -p $'Please type the message for the tag of the branch you\'re releasing. >>>> \n' tagcommand
tagname=braven-release-$now
echo "git tag -a $tagname -m \"$tagcommand\""
git tag -a $tagname -m "$tagcommand"

# Note: to view commits since a certain tag, use: git log <insertYourTagName>..HEAD
# Note: to see the files changes since a certain tag, use:  git diff --name-only <insertYourTagName>..HEAD

if [ $? -ne 0 ]
then
  echo "Failed tagging master"
  exit 1;
fi

# Push the new master branch to github.
git push origin master
git push origin $tagname

if [ $? -ne 0 ]
then
  echo "Failed pushing code to master"
  exit 1;
fi

# Backup the database in case something happens and we want to roll the code back
# If you get in that situation, read this to restore: https://devcenter.heroku.com/articles/pgbackups
heroku pg:backups capture --remote production

if [ $? -ne 0 ]
then
  echo "Failed taking database backup"
  exit 1;
fi

# Push the code
git push production master; heroku run rake db:migrate --remote production; heroku restart --remote production

if [ $? -ne 0 ]
then
  echo "Failed pushing code to heroku production branch, running database migrations, or restarting server"
  exit 1;
fi

else
  echo "Aborted!"
fi


