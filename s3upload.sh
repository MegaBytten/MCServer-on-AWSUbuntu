#!/bin/bash

# Check if the number of arguments is not equal to 1
if [ $# -ne 1 ]; then
  echo "Usage: bash s3upload.sh [name of version]"
  exit 1
fi

# Access the first argument
ARG1=$1

# Upload to unique folder for this specific version
sudo aws s3 sync ~/mcserver/ s3://megabyttenpersonalmcserverbackups/$ARG1

# Update s3::/latest too
sudo aws s3 sync ~/mcserver/ s3://megabyttenpersonalmcserverbackups/latest --delete
