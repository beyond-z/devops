#!/bin/bash
source ~/.env

cd ~/src/kits
git checkout master
git pull origin master
rsync -avz --exclude 'wp-content/uploads' --exclude 'wp-content/updraft' --exclude 'wp-content/cache' --exclude '.git' $KITS_PROD_USER:/var/www/html/ ~/src/kits
