#!/bin/bash
source ~/.env

cd ~/src/kits
git checkout staging
git pull origin staging
rsync -avz --exclude 'wp-content/uploads' --exclude 'wp-content/updraft' --exclude 'wp-content/cache' --exclude '.git' $KITS_STAGING_USER:/var/www/html/ ~/src/kits
