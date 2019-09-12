#/bin/bash

read -r -p "Are you sure you want to release staging to production? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

cd ~/src/canvas/

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
fi

rvm use ruby-2.1.9
# This was for CanvasLMSProduction before we upgraded bundler to v1.15.2
#rvm use ruby-2.1.8
#rvm use ruby-1.9.3-p484
if [ $? -ne 0 ]
then
  echo "Failed loading ruby version"
  exit 1;
fi

# Merge the code from staging to master
git checkout bz-staging; git pull origin bz-staging; git checkout bz-master; git pull origin bz-master; git merge --no-ff bz-staging
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
git push origin bz-master
if [ $? -ne 0 ]
then
  echo "Failed pushing code to master"
  exit 1;
fi

# Push the code
now=$(date +"%Y%m%d")
bundle exec cap production deploy --trace &> ~/logs/canvas/prod_deploy_$now.log

# Note: if you are updating Canvas code significantly, you may have to flush the redis cache.  Try this
# on the remote server if the screen is blank after the deploy:
# redis-cli -r 1 flushall

if [ $? -ne 0 ]
then
  echo "Failed deploying to production"
  exit 1;
fi

~/scripts/lms_release_custom_css_js_prod.bat
if [ $? -ne 0 ]
then
  echo "Failed deploying Custom CSS/JS to production S3 bucket"
  exit 1;
fi

echo "Done deploying code and CSS/JS to production."
echo "IMPORTANT: If there were CSS/JS changes, go update the version string in the settings so the cached version is invalidated!: https://portal.bebraven.org/accounts/1/settings"
else
  echo "Aborted!"
fi
