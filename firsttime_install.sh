#!/bin/bash

# Ensure the script is run with sudo privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo."
   exit 1
fi


echo "Updating package lists..."
sudo apt update >/dev/null

# Installing no GUI Java runtime
echo "Adding Java repository..."
sudo add-apt-repository ppa:openjdk-r/ppa -y >/dev/null

echo "Installing Java (headless)..."
sudo apt install openjdk-21-jre-headless -y >/dev/null

# Install YQ for config reading in bash
echo "Installing yq for YAML parsing..."
sudo apt-get install -y yq >/dev/null 

# Install unzip for AWS unzipping
echo "Installing unzip for AWS installation..."
sudo apt install unzip -y >/dev/null # 



# Get config.yaml location based on Git Repo name
CONFIG_FILE="/home/ubuntu/MCServer_on_AWSUbuntu/config.yaml"

# Getting Ubuntu_path var, because sudo running command resolves $HOME to / (root)
echo "Reading ubuntu_path from config.yaml..."
UBUNTU_PATH=$(yq '.ubuntu_path' "$CONFIG_FILE")



# Installing AWS CLI so we can pull server from S3
echo "Installing AWS CLI..."

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$UBUNTU_PATH/awscliv2.zip" >/dev/null
unzip "$UBUNTU_PATH/awscliv2.zip" >/dev/null
rm -rf "$UBUNTU_PATH/awscliv2.zip" >/dev/null
$UBUNTU_PATH/aws/install >/dev/null

# Make minecraft dir
echo "Creating Minecraft server directory..."
mkdir "$UBUNTU_PATH/mcserver"

# Install latest Minecraft version from AWS S3
echo "Downloading the latest Minecraft version from S3..."
sudo aws s3 cp s3://megabyttenpersonalmcserverbackups/latest "$UBUNTU_PATH/mcserver/" --recursive >/dev/null


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
echo "Updating config.yaml with latest Minecraft server jar..."
yq w $CONFIG_FILE .mcserver_jar $LATEST_JAR

# Run the mcserver_systemd.sh to create a systemD service for MC server
echo "Launching SystemD job..."
sudo bash mcserver_systend.sh

IP=$(hostname -I | awk '{print $1}')
echo "Installation complete, S3::Latest Minecraft server running on $IP" 