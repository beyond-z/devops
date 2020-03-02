#/bin/bash
source ~/scripts/helper_functions.sh
exit_if_no_aws

# TODO: install aws cli on the bebraven prod server and setup a cronjob to do a nightly
# sync of it's files to teh S3 bucket using something like:
# aws s3 sync /var/www/html/wp-content $BRAVEN_S3_STAGING_WP_CONTENT_BUCKET

echo "### Transferring wp-content from BeBraven production to $BRAVEN_S3_STAGING_WP_CONTENT_BUCKET"
echo "so that BeBraven staging and dev can restore from that wp-content"
bebraven_local_wp_content_folder=~/src/braven_2/wp-content
rsync -avz $BRAVEN_PROD_USER:$BRAVEN_PROD_WP_CONTENT_FOLDER/uploads/ $bebraven_local_wp_content_folder/uploads \
  || { echo >&2 "Error: Failed running 'rsync -avz $BRAVEN_PROD_USER:$BRAVEN_PROD_WP_CONTENT_FOLDER/uploads/ $bebraven_local_wp_content_folder/uploads'"; exit 1; }

aws s3 sync $bebraven_local_wp_content_folder/uploads/ $BRAVEN_S3_STAGING_WP_CONTENT_BUCKET/uploads/ \
  || { echo >&2 "Error: Failed running 'aws s3 sync $bebraven_local_wp_content_folder/uploads/ $BRAVEN_S3_STAGING_WP_CONTENT_BUCKET/uploads/'"; exit 1; }

rsync -avz $BRAVEN_PROD_USER:$BRAVEN_PROD_WP_CONTENT_FOLDER/plugins/ $bebraven_local_wp_content_folder/plugins \
  || { echo >&2 "Error: Failed running 'rsync -avz $BRAVEN_PROD_USER:$BRAVEN_PROD_WP_CONTENT_FOLDER/plugins/ $bebraven_local_wp_content_folder/plugins'"; exit 1; }

aws s3 sync $bebraven_local_wp_content_folder/plugins/ $BRAVEN_S3_STAGING_WP_CONTENT_BUCKET/plugins/ \
  || { echo >&2 "Error: Failed running 'aws s3 sync $bebraven_local_wp_content_folder/plugins/ $BRAVEN_S3_STAGING_WP_CONTENT_BUCKET/plugins/'"; exit 1; }

echo "### Done: Transferring wp-content from BeBraven production to $BRAVEN_S3_STAGING_WP_CONTENT_BUCKET"
