#!/bin/bash

# This is currently at /usr/sbin/sendmail on the staging Canvas server. 
# Its purpose is to supress outgoing emails so that we can have staging match production
# data (with sensitive data changed, like the passwords) but not risk emailing real users.
# Note that the original sendmail binary is at /usr/sbin/sendmail.original, 
# which is referenced at the end of this script.

sed -e '
        # Redirect all To recipients to us at the tech team
        0,/^To:/{s/^To: \(.*\)/X-Original-To: \1\r\nTo: tech@beyondz.org/}

        # make all Ccs, if any, just stay here on the local box
        0,/^Cc:/{s/^Cc: \(.*\)/Cc: root@localhost/}
        0,/^Bcc:/{s/^Bcc: \(.*\)/Bcc: root@localhost/}

        # Make the subject include the staging note
        0,/^Subject:/{s/^Subject: \(.*\)/Subject: [STAGINGPORTAL] \1/}
' | sendmail.original $*

