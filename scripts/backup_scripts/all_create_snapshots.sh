#!/bin/bash
source ~/scripts/helper_functions.sh

#####################

# This script creates a snapshot of all production databases and files 
# needed to restore a particular staging or development to match
# production.
####################


# TODO: Currently backups are stored un the bucket in a way where we can use the names to decide what to refresh
# from since we're naming things consistently, but we really should design a tagging system and store the files 
# up there in a way where we can list the available tags and choose the file for a given tag.
# Maybe it's as simple as a little json file on each bucket that stores the tag -> file mapping? If we assume that 
# a snapshot with the same tag will be created for every app whenever we create snapshots (vs one off tagged snapshots)
# then we can not worry about it and just error out if a tage for a specific server is missing.
# I don't think this requirement is the best though. We may want to choose a server nad say "generate" snapshot and be able to 
# do that without having a matching snapshot for all apps.
# Another option is a database solution or a central json file for all apps and associated tags.
# The tag could be a date or it could be the branch of the deploy that kicked of the snapshotting
# process.
#
# Need to design this. I'd rather think though all use cases and design it
# properly to work for all cases instead of a hack like name all files blah_tag.dump and just tacking the 
# tag on.


exit_if_no_aws

now=$(date +"%Y%m%d")
dumps_root_dir=~/dumps

# Note: snapshots in a format that required pg_restore have .dump extenstions
# while those that are gzip'ed sql have .sql.gz extensions.

###################################
########## Canvas server ############
###################################
lms_dump_filename=lms_staging_db_${now}.sql.gz
lms_local_dump_file=${dumps_root_dir}/${lms_dump_filename}

~/scripts/backup_scripts/lms_create_snapshot.sh $lms_local_dump_file

aws s3 cp $lms_local_dump_file $lms_latest_dump_s3_path \
  || { echo >&2 "Error: Failed transfering $lms_local_dump_file to $lms_latest_dump_s3_path"; exit 1; }
aws s3 cp $lms_latest_dump_s3_path ${PORTAL_S3_STAGING_DBS_BUCKET}/snapshots/${lms_dump_filename} \
  || { echo >&2 "Error: Failed transfering $lms_latest_dump_s3_path to ${PORTAL_S3_STAGING_DBS_BUCKET}/snapshots/${lms_dump_filename}"; exit 1; }
rm $lms_local_dump_file

### Copy the uploaded production files over to staging and dev so they can load those files too.
~/scripts/backup_scripts/lms_update_file_uploads.sh

# Note: snapshots in a format that required pg_restore have .dump extenstions
# while those that are gzip'ed sql have .sql.gz extensions.

###################################
########## Booster server ############
###################################
lms_dump_filename=lms_staging_db_${now}.sql.gz
lms_local_dump_file=${dumps_root_dir}/${lms_dump_filename}

~/scripts/backup_scripts/lms_create_snapshot_booster.sh $lms_local_dump_file

aws s3 cp $lms_local_dump_file $lms_booster_latest_dump_s3_path \
  || { echo >&2 "Error: Failed transfering $lms_local_dump_file to $lms_booster_latest_dump_s3_path"; exit 1; }
aws s3 cp $lms_booster_latest_dump_s3_path ${PORTAL_BOOSTER_S3_STAGING_DBS_BUCKET}/snapshots/${lms_dump_filename} \
  || { echo >&2 "Error: Failed transfering $lms_booster_latest_dump_s3_path to ${PORTAL_BOOSTER_S3_STAGING_DBS_BUCKET}/snapshots/${lms_dump_filename}"; exit 1; }
rm $lms_local_dump_file

### Copy the uploaded production files over to staging and dev so they can load those files too.
~/scripts/backup_scripts/lms_booster_update_file_uploads.sh

##################################
######### Join server ############
##################################

join_dump_filename=join_staging_db_${now}.dump
join_local_dump_file=${dumps_root_dir}/${join_dump_filename}

~/scripts/backup_scripts/join_create_snapshot.sh $join_local_dump_file

aws s3 cp $join_local_dump_file $join_latest_dump_s3_path \
  || { echo >&2 "Error: Failed transfering $join_local_dump_file to $join_latest_dump_s3_path"; exit 1; }
aws s3 cp $join_latest_dump_s3_path ${HEROKU_S3_STAGING_DBS_BUCKET}/snapshots/${join_dump_filename} \
  || { echo >&2 "Error: Failed transfering $join_latest_dump_s3_path to ${HEROKU_S3_STAGING_DBS_BUCKET}/snapshots/${join_dump_filename}"; exit 1; }
rm $join_local_dump_file

##################################
######### Kits server ############
##################################

### Main WordPress DB
kits_dump_filename=kits_staging_db_${now}.sql.gz
kits_local_dump_file=${dumps_root_dir}/${kits_dump_filename}

~/scripts/backup_scripts/kits_create_snapshot.sh $KITS_PROD_DB_NAME $kits_local_dump_file

aws s3 cp $kits_local_dump_file $kits_latest_dump_s3_path \
  || { echo >&2 "Error: Failed transfering $kits_local_dump_file to $kits_latest_dump_s3_path"; exit 1; }
aws s3 cp $kits_latest_dump_s3_path ${KITS_S3_STAGING_DBS_BUCKET}/snapshots/${kits_dump_filename} \
  || { echo >&2 "Error: Failed transfering $kits_latest_dump_s3_path to ${KITS_S3_STAGING_DBS_BUCKET}/snapshots/${kits_dump_filename}"; exit 1; }
rm $kits_local_dump_file

### Attendance DB
kits_attendance_dump_filename=kits_staging_attendance_db_${now}.sql.gz
kits_attendance_local_dump_file=${dumps_root_dir}/${kits_attendance_dump_filename}

~/scripts/backup_scripts/kits_create_snapshot.sh $KITS_PROD_ATTENDANCE_DB_NAME $kits_attendance_local_dump_file

aws s3 cp $kits_attendance_local_dump_file $kits_latest_dump_attendance_s3_path \
  || { echo >&2 "Error: Failed transfering $kits_attendance_local_dump_file to $kits_latest_dump_attendance_s3_path"; exit 1; }
aws s3 cp $kits_latest_dump_attendance_s3_path ${KITS_S3_STAGING_DBS_BUCKET}/snapshots/${kits_attendance_dump_filename} \
  || { echo >&2 "Error: Failed transfering $kits_latest_dump_attendance_s3_path to ${KITS_S3_STAGING_DBS_BUCKET}/snapshots/${kits_attendance_dump_filename}"; exit 1; }
rm $kits_attendance_local_dump_file

### Update the S3 backup of prod wp-content that staging and dev can use to restore from.
~/scripts/backup_scripts/kits_update_wp_content_backup.sh


##################################
######### BeBraven dot org server ############
##################################

### Main WordPress DB
bebraven_dump_filename=bebraven_staging_db_${now}.sql.gz
bebraven_local_dump_file=${dumps_root_dir}/${bebraven_dump_filename}

~/scripts/backup_scripts/bebraven_create_snapshot.sh $BRAVEN_PROD_DB_NAME $bebraven_local_dump_file

aws s3 cp $bebraven_local_dump_file $bebraven_latest_dump_s3_path \
  || { echo >&2 "Error: Failed transfering $bebraven_local_dump_file to $bebraven_latest_dump_s3_path"; exit 1; }
aws s3 cp $bebraven_latest_dump_s3_path ${BRAVEN_S3_STAGING_DBS_BUCKET}/snapshots/${bebraven_dump_filename} \
  || { echo >&2 "Error: Failed transfering $bebraven_latest_dump_s3_path to ${BRAVEN_S3_STAGING_DBS_BUCKET}/snapshots/${bebraven_dump_filename}"; exit 1; }
rm $bebraven_local_dump_file

### Mock IV DB
bebraven_mock_iv_dump_filename=bebraven_staging_mock_iv_db_${now}.sql.gz
bebraven_mock_iv_local_dump_file=${dumps_root_dir}/${bebraven_mock_iv_dump_filename}

~/scripts/backup_scripts/bebraven_create_snapshot.sh $BRAVEN_PROD_INTERVIEW_MATCHER_DB_NAME $bebraven_mock_iv_local_dump_file

aws s3 cp $bebraven_mock_iv_local_dump_file $bebraven_latest_dump_mock_iv_s3_path \
  || { echo >&2 "Error: Failed transfering $bebraven_mock_iv_local_dump_file to $bebraven_latest_dump_mock_iv_s3_path"; exit 1; }
aws s3 cp $bebraven_latest_dump_mock_iv_s3_path ${BRAVEN_S3_STAGING_DBS_BUCKET}/snapshots/${bebraven_mock_iv_dump_filename} \
  || { echo >&2 "Error: Failed transfering $bebraven_latest_dump_mock_iv_s3_path to ${BRAVEN_S3_STAGING_DBS_BUCKET}/snapshots/${bebraven_mock_iv_dump_filename}"; exit 1; }
rm $bebraven_mock_iv_local_dump_file

### Update the S3 backup of prod wp-content that staging and dev can use to restore from.
~/scripts/backup_scripts/bebraven_update_wp_content_backup.sh

