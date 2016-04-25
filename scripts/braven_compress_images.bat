#!/bin/bash
read -r -p "Are you sure you want to compress all JPG and PNG files in this and all subdirectories? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

now=$(date +"%Y%m%d")
tar -cvpzf ~/imagesBackup_$now.tar.gz ./

find . -name '*.png' -exec pngquant --ext .png --force 256 {} \;

find . -name '*.jpg' -exec mogrify -strip -interlace Plane -sampling-factor 4:2:0 -quality 85% {} \;

else
  echo "Aborted!"
fi
