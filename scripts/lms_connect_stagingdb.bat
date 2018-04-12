#/bin/bash
source ~/.env

# Have to use internal IP/DNS since firewall is setup to only allow internal connections.
psql -h $PORTAL_STAGING_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d $PORTAL_PROD_DB_NAME
if [ $? -ne 0 ]
then
  echo "Failed connecting to staging database using:"
  echo ""
  echo "psql -h $PORTAL_STAGING_DB_SERVER -p 5432 -U $PORTAL_PROD_DB_USER -w -d $PORTAL_PROD_DB_NAME"
  exit 1;
fi
