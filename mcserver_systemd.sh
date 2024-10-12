#!/bin/bash

# Ensure the script is run with sudo privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo." 
   exit 1
fi

# Define the path of the service file
SERVICE_FILE="/etc/systemd/system/minecraftserver.service"

# Define command for execution based on installation
COMMAND="/bin/java sudo -Xmx15000M -Xms15000M -jar minecraft_server.1.21.1.jar nogui"

# Create or overwrite the .service file with the necessary content
cat <<EOL > $SERVICE_FILE
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/mcserver
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

echo "Minecraft server service file created and enabled."
