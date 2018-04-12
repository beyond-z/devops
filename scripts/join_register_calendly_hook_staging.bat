#!/bin/bash

# Note: I added the trailing slash before the query parameters 
# b/c if I used the same URL as I did for Rutgers, I got this error: 
# {"type":"conflict_error","message":"Hook with this url already exists"}

# Uncomment this to register a new hook
#curl --header "X-TOKEN: $CALENDLY_TOKEN_STAGING" --data "url=https://stagingjoin.bebraven.org/calendly/invitee_action/?magic_token=test&events[]=invitee.created&events[]=invitee.canceled" https://calendly.com/api/v1/hooks

# Uncomment this to list existing hooks
#curl --header "X-TOKEN: $CALENDLY_TOKEN_STAGING" https://calendly.com/api/v1/hooks

# Uncomment this to delete an existing hook, getting the ID using the above command
#curl -X DELETE --header "X-TOKEN: $CALENDLY_TOKEN_STAGING" https://calendly.com/api/v1/hooks/<your_hook_id>
