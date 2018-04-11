#!/bin/bash
source ~/.env

echo "Dropping the staging database.  Run this before refreshing if things get too out of whack"
dropdb -h $PORTAL_STAGING_DB_SERVER -U $PORTAL_PROD_DB_USER canvas_queue_production
dropdb -h $PORTAL_STAGING_DB_SERVER -U $PORTAL_PROD_DB_USER canvas_production
createdb -h $PORTAL_STAGING_DB_SERVER -U $PORTAL_PROD_DB_USER -w canvas_production --owner=canvas
createdb -h $PORTAL_STAGING_DB_SERVER -U $PORTAL_PROD_DB_USER -w canvas_queue_production --owner=canvas

if [ $? -ne 0 ]
then
  echo "Failed dropping Canvas database"
  echo ""
  echo "Double check that you have a ~/.pgpass file with credentials to connect to the staging and prod databases. Note that the ~/.pgpass file should have permissions set to chmod 600.  Example of file contents:"
  echo "$PORTAL_STAGING_DB_SERVER:5432:*:$PORTAL_PROD_DB_USER:yourPass"
  echo "$PORTAL_PROD_DB_SERVER:5432:*:$PORTAL_PROD_DB_USER:yourPass"
  exit 1;
fi

