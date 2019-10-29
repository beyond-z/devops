#/bin/bash
source ~/scripts/helper_functions.sh
exit_if_no_aws

# TODO: install aws cli on the kits prod server and setup a cronjob to do a nightly
# sync of it's files to teh S3 bucket using something like:
# aws s3 sync /var/www/html/wp-content $KITS_S3_STAGING_WP_CONTENT_BUCKET

echo "### Transferring wp-content from Kits production to $KITS_S3_STAGING_WP_CONTENT_BUCKET"
echo "so that Kits staging and dev can restore from that wp-content"
kits_local_wp_content_folder=~/src/kits/wp-content
rsync -avz $KITS_PROD_USER:$KITS_PROD_WP_CONTENT_FOLDER/uploads/ $kits_local_wp_content_folder/uploads \
  || { echo >&2 "Error: Failed running 'rsync -avz $KITS_PROD_USER:$KITS_PROD_WP_CONTENT_FOLDER/uploads/ $kits_local_wp_content_folder/uploads'"; exit 1; }

aws s3 sync $kits_local_wp_content_folder/uploads/ $KITS_S3_STAGING_WP_CONTENT_BUCKET/uploads/ \
  || { echo >&2 "Error: Failed running 'aws s3 sync $kits_local_wp_content_folder/uploads/ $KITS_S3_STAGING_WP_CONTENT_BUCKET/uploads/'"; exit 1; }

rsync -avz $KITS_PROD_USER:$KITS_PROD_WP_CONTENT_FOLDER/plugins/ $kits_local_wp_content_folder/plugins \
  || { echo >&2 "Error: Failed running 'rsync -avz $KITS_PROD_USER:$KITS_PROD_WP_CONTENT_FOLDER/plugins/ $kits_local_wp_content_folder/plugins'"; exit 1; }

aws s3 sync $kits_local_wp_content_folder/plugins/ $KITS_S3_STAGING_WP_CONTENT_BUCKET/plugins/ \
  || { echo >&2 "Error: Failed running 'aws s3 sync $kits_local_wp_content_folder/plugins/ $KITS_S3_STAGING_WP_CONTENT_BUCKET/plugins/'"; exit 1; }

echo "### Done: Transferring wp-content from Kits production to $KITS_S3_STAGING_WP_CONTENT_BUCKET"
