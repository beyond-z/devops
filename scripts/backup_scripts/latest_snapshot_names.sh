#!/bin/bash
source ~/.env

# Filenames and S3 bucket paths for the latest snapshots for all apps.
join_latest_dump_filename=join_staging_db_latest.dump
join_latest_dump_s3_path=${HEROKU_S3_STAGING_DBS_BUCKET}/${join_latest_dump_filename}
