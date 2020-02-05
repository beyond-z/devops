#!/bin/bash
source ~/.env

heroku run bundle exec bin/rails console -a $PORTAL_PROD_APP
