#/bin/bash

cd ~/src/careermgr/

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

git checkout staging; git pull origin staging;
now=$(date +"%Y%m%d")

# TODO: uncomment me once this works
#bundle exec cap staging deploy --trace &> ~/logs/careermgr/staging_deploy_$now.log
#if [ $? -ne 0 ]
#then
#  echo "Failed deploying to staging"
#  exit 1;
#fi
