#/bin/bash

echo "This script is obsolete. Either update it to work with the new https://github.com/bebraven/canvas-lms repo or delete and rollout a new release process to the dev team"
echo "If you update to work with new repo, the branches bz-staging-heroku becomes staging and bz-master-heroku becomes production."
exit 1;

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
git checkout bz-staging-heroku; git pull origin bz-staging-heroku; git checkout bz-master-heroku; git pull origin bz-master-heroku; git merge --no-ff bz-staging-heroku
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
git push origin bz-master-heroku
if [ $? -ne 0 ]
then
  echo "Failed pushing code to master"
  exit 1;
fi

# Note: if you are updating Canvas code significantly, you may have to flush the redis cache.  Try this
# on the remote server if the screen is blank after the deploy:
# redis-cli -r 1 flushall

~/scripts/lms_release_custom_css_js_prod.bat
if [ $? -ne 0 ]
then
  echo "Failed deploying Custom CSS/JS to production S3 bucket"
  exit 1;
fi

echo "Done deploying code to master branch on Heroku and CSS/JS to production."
echo "IMPORTANT: the deploy will not be live until the build finished on Heroku here: https://dashboard.heroku.com/apps/portal-bebraven-dot-org"
echo "IMPORTANT: If there were CSS/JS changes, go update the version string in the settings so the cached version is invalidated!: https://portal.bebraven.org/accounts/1/settings"
else
  echo "Aborted!"
fi
