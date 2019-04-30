#/bin/bash

read -r -p "Are you sure you want to release staging to production? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

cd ~/src/career-mgr/

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
fi

rvm use ruby-2.4.4
if [ $? -ne 0 ]
then
  echo "Failed loading ruby version"
  exit 1;
fi

# Merge the code from staging to master
# TODO: uncomment me once we figure out how to handle the secrets.yml file on this machine and src ctrl
#git checkout staging; git pull origin staging; git checkout master; git pull origin master; git merge --no-ff staging; git push origin master;
git checkout master; git pull origin master; git merge --no-ff staging
if [ $? -ne 0 ]
then
  echo "Failed merging staging to master"
  exit 1;
fi

now=$(date +"%Y-%m-%d.%H%M")
read -r -p $'Please type the message for the tag of the branch you\'re releasing. >>>> \n' tagcommand
tagname=bz-release/$now
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

# Push the code
now=$(date +"%Y%m%d")
bundle exec cap production deploy --trace 2>&1 | tee ~/logs/careermgr/prod_deploy_$now.log

if [ $? -ne 0 ]
then
  echo "Failed deploying to production. See log: ~/logs/careermgr/prod_deploy_$now.log"
  exit 1;
fi

echo "Done deploying Career Manager code to production. The release log is: ~/logs/careermgr/prod_deploy_$now.log"

# If they choose No for the initial prompt
else
  echo "Aborted!"
fi
