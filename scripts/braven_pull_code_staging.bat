#!/bin/bash
source ~/.env

cd ~/src/braven
git checkout staging
git pull origin staging
rsync -avz --exclude 'wp-content/updraft' --exclude 'wp-content/cache' --exclude '.git' $BRAVEN_STAGING_USER:/var/www/ ~/src/braven
