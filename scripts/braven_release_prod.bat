#/bin/bash
source ~/.env

read -r -p "Are you sure you want to release staging to production? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

cd ~/src/braven

# Merge the code from staging to master
git checkout staging; git pull origin staging; git checkout master; git pull; git merge --no-ff staging

if [ $? -ne 0 ]
then
  echo "Failed merging staging to master"
  exit 1;
fi

#echo "Recent tags"
#git tag -n10 | grep braven-release-*

now=$(date +"%Y%m%d_%H%M")
read -r -p $'Please type the message for the tag of the branch you\'re releasing. >>>> \n' tagcommand
tagname=braven-release-$now
echo "git tag -a $tagname -m \"$tagcommand\""
git tag -a $tagname -m "$tagcommand"

if [ $? -ne 0 ]
then
  echo "Failed tagging master"
  exit 1;
fi


# Note: to view commits since a certain tag, use: git log <insertYourTagName>..HEAD
# Note: to see the files changes since a certain tag, use:  git diff --name-only <insertYourTagName>..HEAD

git push origin $tagname

# Push the new master branch to github.
git push origin master
if [ $? -ne 0 ]
then
  echo "Failed pushing code to master"
  exit 1;
fi

ssh $BRAVEN_PROD_USER 'cd /var/www; git pull origin master; chown -R www-data:www-data .; /etc/init.d/apache2 restart'
if [ $? -ne 0 ]
then
  echo "Failed connected to prod server and updating code"
  exit 1;
fi


else
  echo "Aborted!"
fi

