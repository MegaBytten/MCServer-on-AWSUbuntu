#!/bin/bash

# NOTE: Requires functional forge server with mods/ dir at /home/ubuntu/mcserver/mods

# Ensure the script is run with sudo privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo."
   exit 1
fi

# Get config.yaml location based on Git Repo name
PROJECT_DIR="/home/ubuntu/MCServer_on_AWSUbuntu"
CONFIG_FILE="${PROJECT_DIR}/config.yaml"

# Getting Ubuntu_path var, because sudo running command resolves $HOME to / (root)
echo "Reading ubuntu_path from config.yaml..."
UBUNTU_PATH=$(yq -r '.ubuntu_path' "$CONFIG_FILE")

# Download mods:

# COMFORT - DOESNT WORK
# wget -O $UBUNTU_PATH/mcserver/mods/comforts-forge-1.21.jar https://www.curseforge.com/api/v1/mods/276951/files/5718737/download >/dev/null