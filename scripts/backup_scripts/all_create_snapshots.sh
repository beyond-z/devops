#!/bin/bash
source ~/scripts/helper_functions.sh

#####################
# This script creates a snapshot of all production databases and files 
# needed to restore a particular staging or development to match
# production.
####################

# TODO: come up with a standard way to name the snapshots so they can be retrieved.
# All scripts should take the snapshot name as a param and use that so we can control the
# approach to choosing the correct snapshot to restore from centrally.
# E.g. in the future, maybe instead of dates, or in addition to dates, we pass in a "tag". 
# The tag could be a date or it could be the branch of the deploy that kicked of the snapshotting
# process.
# Need to design this. I'd rather think though all use cases and design it
# properly to work for all cases instead of a hack like name all files blah_tag.dump and just tacking the 
# tag on. Eventually, we'll want a want to list what tags are available and choose to restore to that.
# do we store that list in a strcutured file in the bucket? In a database? in a central file? As separate meta files? How?

exit_if_no_aws

now=$(date +"%Y%m%d")
dumps_root_dir=~/dumps

# Note: snapshots in a format that required pg_restore have .dump extenstions
# while those that are gzip'ed sql have .sql.gz extensions.

##################################
######### Join server ############
##################################

join_dump_filename=join_staging_db_${now}.dump
join_local_dump_file=${dumps_root_dir}/${join_dump_filename}

~/scripts/backup_scripts/join_create_snapshot.sh $join_local_dump_file

# TODO: right now, these are stored on the bucket in a way where we can use the names to decide what to refresh
# from since we're naming things consistently, but we really should design a tagging system and store the files 
# up there in a way where we can list the available tags and choose the file for a given tag.
# Maybe it's as simple as a little json file on each bucket that stores the tag -> file mapping? If we assume that 
# a snapshot with the same tag will be created for every app whenever we create snapshots (vs one off tagged snapshots)
# then we can not worry about it and just error out if a tage for a specific server is missing.
# I don't think this requirement is the best though. We may want to choose a server nad say "generate" snapshot and be able to 
# do that without having a matching snapshot for all apps.
# Another option is a database solution or a central json file for all apps and associated tags.

aws s3 cp $join_local_dump_file $join_latest_dump_s3_path \
  || { echo >&2 "Error: Failed transfering $join_local_dump_file to $join_latest_dump_s3_path"; exit 1; }
aws s3 cp $join_local_dump_file ${HEROKU_S3_STAGING_DBS_BUCKET}/snapshots/${join_dump_filename} \
  || { echo >&2 "Error: Failed transfering $join_local_dump_file to ${HEROKU_S3_STAGING_DBS_BUCKET}/snapshots/${join_dump_filename}"; exit 1; }

rm $join_local_dump_file

##################################
######### Kits server ############
##################################

 # TODO
