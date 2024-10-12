#!/bin/bash

PROJECT_DIR="/home/ubuntu/MCServer_on_AWSUbuntu"
CONFIG_FILE="${PROJECT_DIR}/config.yaml"

# Getting Ubuntu_path var, because sudo running command resolves $HOME to / (root)
echo "Reading ubuntu_path from config.yaml..."
UBUNTU_PATH=$(yq -r '.ubuntu_path' "$CONFIG_FILE")
MCDIR="${UBUNTU_PATH}/mcserver"

# Check if the directory exists
if [ ! -d "$MC_DIR" ]; then
  echo "Directory $MC_DIR does not exist!"
  exit 1
fi

# Find all minecraft_server.x.xx.x.jar files in the directory
LATEST_JAR=$(ls "$MC_DIR"/minecraft_server.*.jar 2>/dev/null | sort -V | tail -n 1)

# Check if any .jar files were found
if [ -z "$LATEST_JAR" ]; then
  echo "No minecraft server .jar files found in $MC_DIR."
  exit 1
fi

# Output the path of the latest .jar file
echo "$LATEST_JAR"
