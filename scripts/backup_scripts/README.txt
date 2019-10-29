This folder has scripts to create snaphots / backups of the various databases and files needed for the staging and dev environments to be refreshed from production data.

The all_create_snapshots.sh script is run nightly by the following cronjob:

  SHELL=/bin/bash
  HOME=<insert home directory>
  ### Make sure heroku and awscli are available on the PATH. The all_create_snapshots.sh script needs them
  PATH=~/.local/bin:/usr/local/heroku/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  
  0 5 * * * ~/scripts/backup_scripts/all_create_snapshots.sh > ~/logs/nightly_backups/all_create_snapshots_$(date +\%Y\%m\%d).log 2>&1
