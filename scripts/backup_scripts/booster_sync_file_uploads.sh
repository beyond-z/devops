#!/bin/bash
source ~/scripts/helper_functions.sh

aws s3 sync $PORTAL_S3_PROD_FILES_BUCKET $BOOSTER_PORTAL_S3_PROD_FILES_BUCKET
