#!/bin/bash
source ~/.env

cd ~/src/join/

# This is a temp hacky way assuming there are only 3 items in the cache.
echo 'SalesforceCache.last.destroy!
SalesforceCache.last.destroy!
SalesforceCache.last.destroy!
exit' | heroku run rails console --app $HEROKU_STAGING_APP

