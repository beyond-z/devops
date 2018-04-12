#!/bin/bash

source ~/.env

echo "Below are some examples of calling a hook on the Join server as though it's coming from Salesforce."
echo "You can adapt these to troubleshoot or fix problems."

# Uncomment this to run change_campaigns, which happens when we Close Recruitment or move a Campaign Member
# so their app is associated with the correct Camapign snapshot. 

## Staging
#curl -d 'magic_token=test&contactIds=0031700000jwz6N&oldCampaignId=70117000001DjOJAA0&newCampaignId=701170000018mXK' https://stagingjoin.bebraven.org/salesforce/change_campaigns

## Production
# This particular example is for some Rutgers students who had their change_campaign call fail. Re-running to move them
# from Spring 2018 campaign to Fall 2017 campaign
#curl -d 'magic_token=$HEROKU_SALESFORCE_MAGIC_TOKEN&contactIds=0031J00001EiqvLQAR,0031J00001EjxxHQAR&oldCampaignId=701o0000000ApU4AAK&newCampaignId=7011J000001EnopQAC' https://join.bebraven.org/salesforce/change_campaigns

