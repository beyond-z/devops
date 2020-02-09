#/bin/bash

read -r -p "Are you sure you want to release staging to production? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

cd ~/src/platform/

# Merge the code from staging to production
git checkout staging; git pull origin staging; git checkout production; git pull origin production; git merge --no-ff staging
if [ $? -ne 0 ]
then
  echo "Failed merging staging to production"
  exit 1;
fi

now=$(date +"%Y-%m-%d.%H%M")
read -r -p $'Please type the message for the tag of the branch you\'re releasing. >>>> \n' tagcommand
tagname=release/$now
echo "git tag -a $tagname -m \"$tagcommand\""
git tag -a $tagname -m "$tagcommand"

if [ $? -ne 0 ]
then
  echo "Failed tagging production"
  exit 1;
fi

git push origin $tagname

# Push the new production branch to github.
git push origin production
if [ $? -ne 0 ]
then
  echo "Failed pushing code to production"
  exit 1;
fi

else
  echo "Aborted!"
fi
