#!/bin/bash
source ~/scripts/helper_functions.sh
exit_if_no_aws

echo "### Transferring the files uploaded to the production Booster Portal S3 bucket to staging and dev"
echo "    buckets for those environments to use."
echo ""
echo "Note: this just adds missing files, but doesn't blow anything that the staging or dev"
echo "servers have uploaded. If you ever want to blow away the staging or dev buckets and make"
echo "them match production, you can manually run these same commands with the '--delete' flag"
aws s3 sync $PORTAL_BOOSTER_S3_PROD_FILES_BUCKET $PORTAL_BOOSTER_S3_DEV_FILES_BUCKET

echo "### Done: Transferring the files uploaded to the production Portal S3 bucket to staging and dev buckets"

