#!/bin/bash

# USAGE NOTE:
# requires already running firsttime_install.sh
# This gets and stores latest world download to /home/ubuntu/mcserver

# Ensure the script is run with sudo privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo."
   exit 1
fi


sudo apt update
sudo apt install openjdk-21-jdk-headless -y 

# Get config.yaml location based on Git Repo name
PROJECT_DIR="/home/ubuntu/MCServer_on_AWSUbuntu"
CONFIG_FILE="${PROJECT_DIR}/config.yaml"

# Getting Ubuntu_path var, because sudo running command resolves $HOME to / (root)
echo "Reading ubuntu_path from config.yaml..."
UBUNTU_PATH=$(yq -r '.ubuntu_path' "$CONFIG_FILE")

# Install buildtools and run it
echo "installing buildtools in $UBUNTU_PATH/buildtools"
mkdir $UBUNTU_PATH/buildtools && cd $UBUNTU_PATH/buildtools 
wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar >/dev/null
java -jar BuildTools.jar >/dev/null
cd $UBUNTU_PATH

# move spigot files over to world file
echo "doing stuff..."