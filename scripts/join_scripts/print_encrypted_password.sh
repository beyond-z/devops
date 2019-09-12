#!/bin/bash
if [ -z "$1" ]
then
  echo "Please pass in an email. E.g.: ./print_encrypted_password.sh brian@bebraven.org"
  exit 1
fi
source ~/.env
email=$1
now=$(date +"%Y%m%d.%H%M%S")
#TODO: check arg 1 and make sure it's an email. Retun if not.
savedfile=`pwd`/$1.encpw.$now
echo "Saving encrypted password for $email in $savedfile"
cwd=`pwd`
cd ~/src/join/ && echo "print User.find_by_email(\"$email\").encrypted_password; exit" | heroku run rails console --app $HEROKU_PROD_APP --remote production > $savedfile

# Just grab the last line which is the password
tail -n1 $savedfile > $savedfile.tmp && echo "" >> $savedfile.tmp && mv $savedfile.tmp $savedfile
encpw=$( <$savedfile )
echo "Done. Encrypted password is: $encpw"
echo "Run this command to restore the users password:"
echo ""
echo "./set_password_to_encrypted.sh `basename $savedfile`"
echo ""
