#!/bin/bash
if [ -z "$1" ]
then
  echo "Please pass in a file containing the password. The filename must be in the format: <email>.encpw.<somedate>."
  echo "E.g.: ./set_password_to_encrypted.sh brian@bebraven.org.encpw.20190813.123059"
  echo ""
  echo 'The contents of the file should be the encrypted password. E.g. something like: $2a$10XXXXXXXXXXXXXXXXXXXXXX.v.XXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  exit 1
fi

filewithpass=$( basename $1 )
passtoset=$( <$filewithpass )
email=${filewithpass%%.encpw.*} # Strip out longest string from the end matching ".encpw.*". The whole beginning is assumed to be the email.

#TODO: could put some safety measures in. LIke making sure the PW and email is in the right format.

if [ -z "$filewithpass" ] || [ -z "$passtoset" ] || [ -z "$email" ]
then
  echo "Error: one of the following is empty:"
  echo "  file=$filewithpass"
  echo "  encpw=$passtoset"
  echo "  email=$email"
  echo "Check the filename and contents match the expected format."
  exit 1
else
  echo "Processing $filewithpass and setting enc password to $passtoset for $email"
fi

cd ~/src/join/ 
cat <<EOF | heroku run rails console --app $HEROKU_PROD_APP --remote production
  u = User.find_by_email("$email")
  u.encrypted_password = "$passtoset"
  u.save
  exit
EOF

