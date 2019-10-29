#!/bin/bash
source ~/.env
source ~/scripts/backup_scripts/latest_snapshot_names.sh

# TODO: add function to get the current directory the script is running from

function exit_if_no_aws {
  aws --version  >/dev/null 2>&1 || { 
    echo >&2 "Error: Please install 'aws'. E.g."
    echo >&2 "   $ pip3 install awscli"; 
    echo >&2 ""
    echo >&2 "You must run 'aws configure' after to setup permissions. Enter your IAM Access Token and Secret. Use us-west-1 for the region."
    exit 1; 
  }
}
