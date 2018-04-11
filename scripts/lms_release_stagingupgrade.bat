#/bin/bash

cd ~/src/canvas/

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
fi
#rvm use ruby-1.9.3-p484
#rvm use ruby-2.1.8
rvm use ruby-2.3.3
if [ $? -ne 0 ]
then
  echo "Failed loading ruby version"
  exit 1;
fi

git checkout upgrade_code_20170118
git pull origin upgrade_code_20170118
now=$(date +"%Y%m%d")
bundle exec cap stagingupgrade deploy --trace &> ~/logs/canvas/stagingupgrade_deploy_$now.log
if [ $? -ne 0 ]
then
  echo "Failed deploying to staging"
  exit 1;
fi

~/scripts/lms_release_custom_css_js_staging.bat
if [ $? -ne 0 ]
then
  echo "Failed deploying Custom CSS/JS to staging S3 bucket"
  exit 1;
fi
