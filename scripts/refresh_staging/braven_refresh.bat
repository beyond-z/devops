#/bin/bash

prod_server=bebraven.org
staging_server=staging.bebraven.org

echo "Taking BeBraven staging backup"
echo "NOT IMPLEMENTED!" # TODO: figure out how to programmatically kick off a backup.  Right now, done manually using updraftplus plugin.

echo "Transferring code from BeBraven production to staging"
echo "NOT IMPLEMENTED!" # TODO: implement this

echo "Transferring database from BeBraven production to staging"
echo "NOT IMPLEMENTED!" # TODO: implement this

#TODO: update this script to update teh staging database with the proper URLs and passwords
#pg_dump --clean -h $prod_server -p 5432 -U canvas -w -d canvas_production | sed -e '
#  # SSO config
#  s/sso.beyondz.org/stagingsso.beyondz.org/g;
#  # Main site
#  s/www.beyondz.org/staging.beyondz.org/g;
#  # Also fix up internal links in assignments to stay on staging as we navigate
#  s/portal.beyondz.org/stagingportal.beyondz.org/g;
#
#  # CSS/JS config 
#  s/canvas-prod-assets/canvas-stag-assets/g;
#
#  # BTW Passwords are done via SSO so we dont have to try to change them here
#' | psql -h $staging_server -p 5432 -U canvas -w -d canvas_production

if [ $? -ne 0 ]
then
  echo "Failed transfering BeBraven database from production to staging."
fi
