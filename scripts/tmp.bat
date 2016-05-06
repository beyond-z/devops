#!/bin/bash
source ~/.env
escaped_prod_bucket=${PORTAL_S3_PROD_BUCKET//s3:\/\/}
echo $escaped_prod_bucket
escaped_prod_bucket=${PORTAL_S3_PROD_BUCKET//\//\\/}

