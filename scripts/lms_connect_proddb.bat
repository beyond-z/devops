#/bin/bash
source ~/.env

heroku pg:psql -a $PORTAL_PROD_APP
