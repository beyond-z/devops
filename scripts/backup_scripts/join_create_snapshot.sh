#!/bin/bash
source ~/scripts/helper_functions.sh
if [ -z "$1" ]
then
  echo "Please pass in the file to store the snapshot in. E.g.: ./join_create_snapshot.sh ~/dumps/join_staging_db_20191023.dump"
  exit 1
fi

echo "### Snapshotting production Join database and creating a staging database from it and then pushing to an S3 bucket for the dev and staging servers to restore from"
dump_file=$1
cd ~/src/join/

# Note: this app is there to function as a playground where we can create DB snapshots.
# there is no actual app, it's just a DB that we can reset, put what we need in it
# operate on it, and create a snapshot from that.
heroku pg:reset DATABASE --app $HEROKU_SNAPSHOTS_APP --confirm $HEROKU_SNAPSHOTS_APP

# Here is the generic version of the following command, old-app is production (where we transfer from)
# and new app is staging (where we transfer to):
#     heroku pgbackups:copy old-application::OLD_APP_DB_NAME NEW_APP_DB_NAME -a new-application
echo "Taking snapshot of production and storing it in $HEROKU_SNAPSHOTS_APP"
heroku pg:copy $HEROKU_PROD_APP::$HEROKU_PROD_DB DATABASE --app $HEROKU_SNAPSHOTS_APP --confirm $HEROKU_SNAPSHOTS_APP \
  || { echo >&2 "Error: failed taking snapshot of production."; exit 1; }

echo "Migrating production snapshot to staging snapshot"

# TODO: double check that there aren't other things that need to be sanitized.
echo "Sanitizing all passwords in staging snapshot"
echo "update users set encrypted_password = '$HEROKU_STAGING_ENCRYPTED_DEV_PASS';" | heroku pg:psql --app $HEROKU_SNAPSHOTS_APP \
  || { echo >&2 "Error: failed sanitizing all passwords in staging snapshot"; exit 1; }

# Note: in the future, we probably won't download and store backups on S3.
# We'll just use Heroku's built-in continuous protection and pg:backups capture for creating
# longer lived snapshots. We'll have to pay for an upgraded plan that can store more snapshots
# (Hobby Basic only stores 5 and drops the oldest one each time you run pg:backups).
# Then staging and dev envs can pull directly from Heroku. For now, just be consistent with how
# we're doing things for all the other apps.
# See: https://devcenter.heroku.com/articles/heroku-postgres-import-export
echo "Preparing for download of snapshot"
heroku pg:backups capture --app $HEROKU_SNAPSHOTS_APP \
  || { echo >&2 "Error: command 'heroku pg:backups capture --app $HEROKU_SNAPSHOTS_APP' failed."; exit 1; }
echo "Downloading snapshot to $dump_file"
heroku pg:backups:download -o $dump_file --app $HEROKU_SNAPSHOTS_APP \
  || { echo >&2 "Error: command 'heroku pg:backups:download -o $dump_file --app $HEROKU_SNAPSHOTS_APP' failed."; exit 1; }

