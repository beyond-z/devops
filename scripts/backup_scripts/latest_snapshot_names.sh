#!/bin/bash
source ~/.env

# Filenames and S3 bucket paths for the latest snapshots for all apps.
lms_latest_dump_filename=lms_staging_db_latest.sql.gz
lms_latest_dump_s3_path=${PORTAL_S3_STAGING_DBS_BUCKET}/${lms_latest_dump_filename}
join_latest_dump_filename=join_staging_db_latest.dump
join_latest_dump_s3_path=${HEROKU_S3_STAGING_DBS_BUCKET}/${join_latest_dump_filename}
kits_latest_dump_filename=kits_staging_db_latest.sql.gz
kits_latest_dump_s3_path=${KITS_S3_STAGING_DBS_BUCKET}/${kits_latest_dump_filename}
kits_latest_dump_attendance_filename=kits_staging_attendance_db_latest.sql.gz
kits_latest_dump_attendance_s3_path=${KITS_S3_STAGING_DBS_BUCKET}/${kits_latest_dump_attendance_filename}
