#!/bin/bash
sudo apt update

# GLOBAL VARS
CONFIG_FILE="config.yaml"

# Ensure the script is run with sudo privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo." 
   exit 1
fi


# Installing no GUI Java runtime
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt install openjdk-21-jre-headless -y

# Install YQ for config reading in bash
sudo apt-get install -y yq


# Installing AWS so we can pull server from S3
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$HOME/awscliv2.zip"
unzip $HOME/awscliv2.zip
rm -rf $HOME/awscliv2.zip
sudo $HOME/aws/install

# Make minecraft dir
mkdir $HOME/mcserver

# Install latest mc version from AWS S3
sudo aws s3 cp s3://megabyttenpersonalmcserverbackups/latest $HOME/mcserver/ --recursive



# Call the script to find the latest Minecraft jar file and capture the output
LATEST_JAR=$(bash latest_mcserver.sh)

# Check if the LATEST_JAR variable is not empty
if [ -z "$LATEST_JAR" ]; then
  echo "Error: No Minecraft server .jar file found."
  exit 1
fi

# Now you can use the $LATEST_JAR variable in other commands or scripts
echo "The latest Minecraft server jar is: $LATEST_JAR"

# Update the config.yaml file by setting the 'mcserver_jar' variable
yq e -i ".mcserver_jar = \"$LATEST_JAR\"" "$CONFIG_FILE"

# Run the mcserver_systemd.sh to create a systemD service for MC server
sudo bash mcserver_systend.sh