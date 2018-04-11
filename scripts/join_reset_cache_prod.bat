#!/bin/bash
source ~/.env
cd ~/src/join/ && echo "Rails.cache.clear; exit;" | heroku run rails console --app $HEROKU_PROD_APP --remote production
