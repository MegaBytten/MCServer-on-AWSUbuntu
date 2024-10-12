#!/bin/bash'

# GLOBAL VARS
CONFIG_FILE="config.yaml"
SERVICE_FILE="/etc/systemd/system/minecraftserver.service"

# Use yq to extract config vals from config.yaml
MEMORY=$(yq e '.mcserver_memory' "$CONFIG_FILE")
MC_JAR_PATH=$(yq e '.mcserver_jar' "$CONFIG_FILE")

COMMAND="/bin/java sudo -Xmx${MEMORY}M -Xms${MEMORY}M -jar $MC_JAR_PATH nogui"

# Create or overwrite the .service file with the necessary content
cat <<EOL > $SERVICE_FILE
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=ubuntu
WorkingDirectory=$HOME/mcserver
ExecStart=$COMMAND
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOL

# Set the correct file permissions
chmod 644 $SERVICE_FILE

# Reload systemd to acknowledge the new service file
systemctl daemon-reload

# Enable the Minecraft service so it starts on boot
systemctl enable minecraftserver.service
systemctl start minecraftserver.service

echo "Minecraft server service file created and enabled."
