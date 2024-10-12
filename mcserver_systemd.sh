#!/bin/bash'

# Get config.yaml location based on Git Repo name
PROJFOLDERPATH="/home/ubuntu/MCServer_on_AWSUbuntu/config.yaml"

SERVICE_FILE="/etc/systemd/system/minecraftserver.service"

# Use yq to extract config vals from config.yaml
MEMORY=$(yq e '.mcserver_memory' "$CONFIG_FILE")
MC_JAR_PATH=$(yq e '.mcserver_jar' "$CONFIG_FILE")

COMMAND="/bin/java sudo -Xmx${MEMORY}M -Xms${MEMORY}M -jar $MC_JAR_PATH nogui"

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
