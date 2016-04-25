#!/bin/bash

cd ~

###########
# Setup Git
###########
if ! git --version &> /dev/null; then
  echo "Installing git"
  sudo apt-get install git
  git config --global user.name "Admin Server"
  git config --global user.email "admin@bebraven.org"
fi

###########
# Setup RVM
###########
if ! rvm --version &> /dev/null; then
  echo "Installing rvm"
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  curl -L get.rvm.io | bash -s stable
  source ~/.rvm/scripts/rvm
  rvm requirements
fi

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
fi

if ! rvm list | grep -Fq "ruby-2.2.3" ; then
  echo "Installing Ruby v2.2.3"
  rvm install 2.2.3
fi

if ! rvm list | grep -Fq "ruby-2.1.8" ; then
  echo "Installing Ruby v2.1.8"
  rvm install 2.1.8
fi

###########
# Get source code and setup directory skeleton for scripts.
###########
echo "Cloning source code (if necessary)"
mkdir -p src
if [ ! -d src/braven/.git ]; then
  clone_cmd_to_run="git clone https://github.com/beyond-z/braven.git src/braven"
  echo "Running: $clone_cmd_to_run"
  $clone_cmd_to_run || { echo >&2 "FAILED."; exit 1; }
fi

if [ ! -d src/canvas/.git ]; then
  clone_cmd_to_run="git clone https://github.com/beyond-z/canvas-lms.git src/canvas"
  echo "Running: $clone_cmd_to_run"
  $clone_cmd_to_run || { echo >&2 "FAILED."; exit 1; }
fi

if [ ! -d src/canvas-js-css/.git ]; then
  clone_cmd_to_run="git clone https://github.com/beyond-z/canvas-lms-js-css.git src/canvas-js-css"
  echo "Running: $clone_cmd_to_run"
  $clone_cmd_to_run || { echo >&2 "FAILED."; exit 1; }
fi

if [ ! -d src/join/.git ]; then
  clone_cmd_to_run="git clone https://github.com/beyond-z/beyondz-platform.git src/join"
  echo "Running: $clone_cmd_to_run"
  $clone_cmd_to_run || { echo >&2 "FAILED."; exit 1; }
fi

echo "Setting up logs and dumps directories for admin scripts"
mkdir -p dumps/~archive
mkdir -p logs/braven
mkdir -p logs/canvas
mkdir -p logs/join

###########
# Setup AWS client
###########
if ! aws --version 2> /dev/null; then
  echo "Installing aws client"
  sudo bin/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
  echo "You must run 'aws configure' to setup permissions and then re-run this setup script."
  echo "Use the braven-admin access keys"
  exit 1;
fi

###########
# Pull secret info into place (like SSH keys)
###########
echo "Pulling secrets from s3://beyondz-secrets to proper locations"
aws s3 sync s3://beyondz-secrets/sshkeys keys
sudo chmod -R 600 keys/*
sudo chmod 700 keys

aws s3 sync s3://beyondz-secrets/sslcerts scripts/sslcerts
sudo chmod 644 scripts/sslcerts/*
sudo chmod 640 scripts/sslcerts/*.key
# On the real server, give the following ownership
#sudo chown root:root scripts/sslcerts/*
#sudo chown root:ssl-cert scripts/sslcerts/*.key

aws s3 cp s3://beyondz-secrets/.env ~/.env
sudo chmod 640 ~/.env

aws s3 cp s3://beyondz-secrets/.join-env-staging src/join/.env-staging
aws s3 cp s3://beyondz-secrets/.join-env-prod src/join/.env-prod
sudo chmod 640 src/join/.env*

source ~/.env

###########
# Heroku Join server setup
###########
if ! heroku --version &> /dev/null; then
  echo "Installing heroku client"
  wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh
  echo "Enter your heroku admin@beyondz.org credentials"
  heroku login
  heroku plugins:install git://github.com/ddollar/heroku-config.git
  (cd src/join && heroku git:remote -a $HEROKU_PROD_APP.git -r production)
  (cd src/join && heroku git:remote -a $HEROKU_STAGING_APP.git -r staging)
fi

###########
# Canvas Capistrano setup
###########
(
cd ~/src/canvas && rvm use 2.1.8 &> /dev/null
if ! bundle exec cap -V &> /dev/null; then 
  echo "Installing Canvas capistrano deploy prerequisites"
  # Setup some stuff that we need to deploy the Portal code using Capaistrano
  sudo apt-add-repository -y ppa:brightbox/ruby-ng
  sudo apt-get update
  sudo apt-get install zlib1g-dev libxml2-dev postgresql-client-9.3 libmysqlclient-dev libxslt1-dev imagemagick libpq-dev nodejs libxmlsec1-dev libcurl4-gnutls-dev libxmlsec1 build-essential openjdk-7-jre unzip ruby2.1-dev
  gem install bundler --version 1.7.11 
  bundle install --path vendor/bundle --without=sqlite mysql

  echo "IMPORTANT!! To finish setting up Capistrano so that the lms_release*.bat scripts work, do the following:"
  echo "  Go to: https://github.com/settings/ssh"
  echo "  Add the ~/.ssh/id_rsa.pub key"
  echo "  Also add the id_rsa.pub key to /home/deploy/.ssh/authorized_keys on each Canvas server"
  echo ""
  echo "Note: if you get 'Too many authentication failures for deploy' when deploying,"
  echo "open ~/.ssh/config and add the IdentitiesOnly setting for each server" 
  echo "  e.g.: "
  echo "  Host <insert host name>"
  echo "  IdentityFile ~/.ssh/id_rsa"
  echo "  IdentitiesOnly yes"
  echo "  Port 22"

fi
)


###########
# SSH access setup
###########

# Make sure that ssh-agent is running everytime we load the
# shell by adding this to ~/.bash_profile
if ! grep -Fq "SSH_AUTH_SOCK" ~/.bash_profile ; then

  echo "Setting up SSH access to servers"

  echo '

# Make sure the ssh-agent is running
# Note: for servers at the bottom of the list, youll get a "Too many authentication failures" message.  
# To prevent this, I added those to ~/.ssh/config with the IdentitiesOnly option    
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
  for file in ~/keys/*
  do
    ssh-add "$file"
  done
fi
' >> ~/.bash_profile

  echo "IMPORTANT!! Please reload the current shell for the admin scripts to work"
fi
