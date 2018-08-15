#/bin/bash
source ~/.env

# Have to use internal IP/DNS since firewall is setup to only allow internal connections.
psql -h $CAREER_MGR_PROD_DB_SERVER -p 5432 -U $CAREER_MGR_PROD_DB_USER -w -d $CAREER_MGR_PROD_DB_NAME
if [ $? -ne 0 ]
then
  echo "Failed connecting to Career Manager production database using:"
  echo ""
  echo "psql -h $CAREER_MGR_PROD_DB_SERVER -p 5432 -U $CAREER_MGR_PROD_DB_USER -w -d $CAREER_MGR_PROD_DB_NAME"
  exit 1;
fi
