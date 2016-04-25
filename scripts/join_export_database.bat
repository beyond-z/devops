#!/bin/bash
source ~/.env

cd ~/src/join/
heroku pgbackups:capture --remote staging --app $HEROKU_STAGING_APP --expire
curl -o latest.dump `heroku pgbackups:url --remote staging --app $HEROKU_STAGING_APP`

# Use something like this to import it into the local database
# pg_restore --clean -U <username> -d <database_name> ../latest.dump

# You'll need to reset passwords to login since the salt and hash are different locally.  Something like:
# rails console
# user = User.where(:email => 'test+admin@beyondz.org').first 
# user.password = 'someTestPass123' 
# user.save 

