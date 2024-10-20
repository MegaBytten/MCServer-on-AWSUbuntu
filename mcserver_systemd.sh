#!/bin/bash'

# Get config.yaml location based on Git Repo name
PROJECT_DIR="/home/ubuntu/MCServer_on_AWSUbuntu"
CONFIG_FILE="${PROJECT_DIR}/config.yaml"

# Ubuntu path used in WorkingDirectory
UBUNTU_PATH=$(yq -r '.ubuntu_path' "$CONFIG_FILE")

# Use yq to extract config vals from config.yaml
MEMORY=$(yq -r '.mcserver_memory' "$CONFIG_FILE")

# Array of current acceptable CLI args for different jars
# service will fail if jar not found, so ensure forge/spigot installed.
CLI_OPTIONS=("spigot" "forge")


# Check if a command-line argument is provided
if [ -z "$1" ]; then
  # No argument provided, use the default value from config.yaml
  MC_JAR_PATH=$(yq -r '.mcserver_jar' "$CONFIG_FILE")
  echo "No CLI argument provided. Defaulting to vanilla server. Options: $CLI_OPTIONS"
elif [ "$1" == "spigot" ]; then
  # If argument is "spigot", use the Spigot jar
  MC_JAR_PATH="/path/to/spigot-1.21.1.jar"
  echo "Spigot jar selected: $MC_JAR_PATH"
else
  # No argument provided, use the default value from config.yaml
  MC_JAR_PATH=$(yq -r '.mcserver_jar' "$CONFIG_FILE")
  echo "Unrecognised CLI argument provided. Defaulting to vanilla server. Options: $CLI_OPTIONS"
fi


if [ "$1" == "spigot" ]; then
  echo "Spigot jar selected."
else
  echo "Not Spigot."
fi
if [ -z "$1" ]; then
  # If no argument provided, use the default value from config.yaml
  # runs a vanilla mc server
  MC_JAR_PATH=$(yq -r '.mcserver_jar_vanilla' "$CONFIG_FILE")
  echo "No command-line argument provided. Using default jar path from config.yaml: $MC_JAR_PATH"
else
  # If an argument is provided, use it as the Minecraft .jar file path
  MC_JAR_PATH=$(yq -r '.mcserver_jar_spigot' "$CONFIG_FILE")
  echo "Using jar file provided as command-line argument: $MC_JAR_PATH"
fi

# where systemd mc server .service file located - to write/overwrite
SERVICE_FILE="/etc/systemd/system/minecraftserver.service"

# create mcserver execution command based on config.yaml memory and CLI args for which file to run
COMMAND="/bin/java -Xmx${MEMORY}M -Xms${MEMORY}M -jar $MC_JAR_PATH nogui"

# Create or overwrite the .service file with the necessary content
echo "Writing data to systemd service file: $SERVICE_FILE..."
cat <<EOL > $SERVICE_FILE
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=ubuntu
WorkingDirectory=$UBUNTU_PATH/mcserver
ExecStart=$COMMAND
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOL

# Set the correct file permissions
chmod 644 $SERVICE_FILE

# Reload systemd to acknowledge the new service file
echo "Reloading systemctl"
systemctl daemon-reload

# Enable the Minecraft service so it starts on boot
echo "Enabling and Starting $SERVICE_FILE..."
systemctl enable minecraftserver.service
systemctl start minecraftserver.service
