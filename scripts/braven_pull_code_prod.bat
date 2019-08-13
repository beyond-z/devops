#!/bin/bash
source ~/.env

cd ~/src/braven_2
git checkout master 
git pull origin master
rsync -avz --exclude '**tar.gz**' --exclude 'wp-content/updraft' --exclude 'wp-content/updraftplus' --exclude 'wp-content/cache' --exclude '.git' $BRAVEN_PROD_USER:/var/www/html/ ~/src/braven_2
