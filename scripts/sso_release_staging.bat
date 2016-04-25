echo "Please write me!"

TODO: write script that does the following against staging.  Then create prod version.

1. Ensure that the master branch is up to date with what you want to deploy.
2. Connect to the server
3. su casadmin
4. cd /var/rubycas-server
5. git pull
6. sudo /etc/init.d/apache2 restart
