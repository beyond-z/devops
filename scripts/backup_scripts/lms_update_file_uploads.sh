#!/bin/bash
source ~/scripts/helper_functions.sh
exit_if_no_aws

echo "### Transferring the files uploaded to the production Portal S3 bucket to staging and dev"
echo "    buckets for those environments to use."
echo ""
echo "Note: this just adds missing files, but doesn't blow anything that the staging or dev"
echo "servers have uploaded. If you ever want to blow away the staging or dev buckets and make"
echo "them match production, you can manually run these same commands with the '--delete' flag"
aws s3 sync $PORTAL_S3_PROD_FILES_BUCKET $PORTAL_S3_STAGING_FILES_BUCKET
aws s3 sync $PORTAL_S3_STAGING_FILES_BUCKET $PORTAL_S3_DEV_FILES_BUCKET

# These commands would delete all files in staging and dev that are not on production.
# See note above.
#aws s3 sync $PORTAL_S3_PROD_FILES_BUCKET $PORTAL_S3_STAGING_FILES_BUCKET --delete
#aws s3 sync $PORTAL_S3_STAGING_FILES_BUCKET $PORTAL_S3_DEV_FILES_BUCKET --delete

echo "### Done: Transferring the files uploaded to the production Portal S3 bucket to staging and dev buckets"

