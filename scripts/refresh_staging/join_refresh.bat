#!/bin/bash
source ~/.env

cd ~/src/join/

echo "Backing up staging database"
heroku pg:backups capture --remote staging

# Note: I was getting errors like this if I didn't reset the staging database first.
#  -- create_table(:salesforce_caches)
#  PG::DuplicateTable: ERROR:  relation "salesforce_caches" already exists
#  : CREATE TABLE "salesforce_caches" ("id" serial primary key, "key" character varying(255), "value" text, "created_at" timestamp, "updated_at" timestamp) 
#  rake aborted!
heroku pg:reset DATABASE --app $HEROKU_STAGING_APP --confirm $HEROKU_STAGING_APP

# Connect to staging and transfer from production database
# Here is the generic version of the following command, old-app is production (where we transfer from)
# and new app is staging (where we transfer to):
#     heroku pgbackups:copy old-application::OLD_APP_DB_NAME NEW_APP_DB_NAME -a new-application
echo "Refreshing stagingjoin.bebraven.org database from the production join.bebraven.org one"
heroku pg:copy $HEROKU_PROD_APP::$HEROKU_PROD_DB $HEROKU_STAGING_DB -a $HEROKU_STAGING_APP --confirm $HEROKU_STAGING_APP --remote staging
if [ $? -ne 0 ]
then
  echo "Failed refreshing database from production"
  exit 1
fi

echo "Migrating the staging database in case there were schema changes"
heroku run rake db:migrate --remote staging

echo "Sanitizing all passwords in staging"
# Was too slow to do in ruby b/c it would kick off all hooks and validations. Just do it at the database level.
#cat ~/scripts/refresh_staging/join_sanitize_staging_passwords.rb | heroku run rails console --app $HEROKU_STAGING_APP --remote staging
echo "update users set encrypted_password = '$HEROKU_STAGING_ENCRYPTED_TEST1234_PASS';" | heroku pg:psql --app $HEROKU_STAGING_APP --remote staging

echo "Taking staging db dump to create dev db so it can be pushed to the db dumps bucket on S3 for the developement env to access (done in parent script)"
mv ~/dumps/join_*.sql.gz ~/dumps/~archive
now=$(date +"%Y%m%d")
heroku pg:backups capture --remote staging
curl `heroku pg:backups public-url --app $HEROKU_STAGING_APP` | gzip > ~/dumps/join_dev_db_dump_$now.sql.gz
