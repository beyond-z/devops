# OVERVIEW:
These are the scripts and setup required to administer the staging and production servers.
You clone it to the home directory on a new server and run setup.bat.

The postgres DB connection passwords are stored in: ~/.pgpass

# Troubleshooting:
If you get an error message connecting to a server that says: "Too many authentication failures for <blah>"
then open up ~/.ssh/config and add a section to map that host to the appropriate SSH key
