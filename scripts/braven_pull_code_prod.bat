#!/bin/bash
source ~/.env

cd ~/src/braven
git checkout master 
git pull origin master
rsync -avz --exclude 'wp-content/updraft' --exclude 'wp-content/cache' --exclude '.git' $BRAVEN_PROD_USER:/var/www/ ~/src/braven
