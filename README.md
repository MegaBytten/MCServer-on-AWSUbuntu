# Minecraft Server Setup on AWS Ubuntu
This repository contains a set of Bash scripts designed to automate the process of setting up a Minecraft (MC) server on an AWS Ubuntu instance. The server can be configured to run either Forge (for mods) or Spigot (for plugins). The scripts handle the installation of dependencies, configuration of the server, and setting up the server as a systemd service for easy management.  


## Overview
This project automates the setup of a Minecraft server on AWS Ubuntu. The scripts support both Forge (for modded Minecraft) and Spigot (for plugin support) and are primarily focused on initial server setup, as there are numerous dependencies and configurations required.  

The repository is designed to provide reproducibility for setting up a Minecraft server and can be used by anyone looking to host a server on AWS with the canonical Ubuntu AMI.  


## Summary of Usage:
Initial Setup: Run firsttime_install.sh to install dependencies and set up the Minecraft server. Then, use either firsttime_spigot.sh or firsttime_forge.sh to install the specific server type. firsttime_install.sh will also download the latest/* files from s3.  
Systemd Service Management: Use mcserver_systemd.sh to set up the Minecraft server as a systemd service.  
Mod Installation: Use forgemods_install.sh to download and install mods for the Forge server.  
Backup: Use s3upload.sh to back up the server to AWS S3.  
For more information, see detailed usage at the bottom of README.md  

## AWS EC2 Guidance:
Instance type: t3.xlarge - 4 vCPUs, 16.0 GiB of memory, <=5 Gibps of bandwidth, Spot: $0.0553/hr
Networking: EBS are AZ-specific, so if attaching a server drive ensure EC2 is deployed in same AZ
Security Group: Ensure SSH (port 22) for connectivity, and port TCP/25565 for minecraft hosting.
IAM Role: Needs S3 full access permission to get/set backups to S3.
EBS Volume: EBS Pricing is provisioned! Cheaper to backup and read from S3 than run multiple EBS backups. Provision ~30GB max.
Spot Instance: Ensure interruption-behaviour = STOP, not TERMINATE. Ensure spot request is PERSISTENT so you can STOP/START server.


## Requirements
The scripts assume the server is running on an AWS Ubuntu instance, which has git pre-installed. The following dependencies will be installed by the scripts if they are not already available:  

Java 21 (Headless) JDK and JRE   
AWS CLI (Set/Get server files from S3)  
YQ (for parsing config.yaml)  
BuildTools (Spigot Only)  
Forge 52.0.x or Spigot 1.21.x  


## Installation
To set up the Minecraft server on your AWS Ubuntu instance, follow these steps:  

### Clone the repository:
```
git clone https://github.com/MegaBytten/MCServer_on_AWSUbuntu.git  
cd MCServer_on_AWSUbuntu  
```

### Run the first-time setup script:
The main setup script installs all required dependencies and sets up your Minecraft server.  
```
sudo bash firsttime_install.sh  
```

### Choose your Minecraft version:
By default, the server will use the vanilla minecraft .jar specified in the config.yaml file. If you are hosting the minecraft vanilla, spigot, or forge .jar files not in /home/ubuntu/mcserver/, you must manually override this in the config.yaml, or in the /etc/systemd/system/minecraftserver.service systemd file. If you are hosting a spigot .jar in the /home/ubuntu/mcserver/ directory, you can simply pass "spigot" as a CLI arg into the "mcserver_systemd.sh" script like the following:  
``` sudo bash firsttime_install.sh spigot ```


### Service Management:
The setup script will create a systemd service to run the MC server, allowing for easy start, stop, and restart commands:  
```
sudo systemctl start minecraftserver  
sudo systemctl stop minecraftserver  
sudo systemctl restart minecraftserver  
```


## Configuration
config.yaml  
> ubuntu_path - change this if home directory is not /home/ubuntu  
> mcserver_memory - change this to vary the allocated memory to server in Megabytes  
> mcserver_jar_vanilla - change this to specify the path to the executable vanilla MC server .jar file. Note: you will likely need to change the systemd minecraftserver.service "WorkingDirectory" field.  
> mcserver_jar_spigot - change this to specify the path to the executable spigot MC server .jar file.  

### Mod and Plugin Installation
Forge Mods: Mods can be found on CurseForge and must be placed in the mods/ directory inside the Minecraft server directory.  
Spigot Plugins: Plugins can be found on SpigotMC and must be placed in the plugins/ directory inside the Minecraft server directory.  
Make sure to restart the server after installing any mods or plugins.  

###  Switching Between Forge and Spigot
You can switch between Forge and Spigot by updating the Minecraft .jar file and restarting the server. If you modify the systemd service file, you must reload the systemctl daemon and restart the service:  
"""
# Example: Switch to Spigot
sudo bash firsttime_install.sh spigot  

# After updating the .service file, reload systemd
sudo systemctl daemon-reload  
sudo systemctl restart minecraftserver  
"""

## Troubleshooting
If you encounter issues with server startup or mod/plugin installation, ensure the following:  

- The .jar file is compatible with the specified Minecraft version (1.21.x for Vanilla, Forge 52.0.x for modded servers).  
- Dependencies such as yq and Java are correctly installed (this is handled by the setup script).  
- Ensure that any mods or plugins are placed in the correct directories and are version-compatible.  

## Project Structure
├── firsttime_install.sh         # Main script for the initial Minecraft server setup  
├── firsttime_spigot.sh          # Spigot-specific setup script  
├── firsttime_forge.sh           # Forge-specific setup script  
├── forgemods_install.sh         # Script to install mods for a Forge server  
├── mcserver_systemd.sh          # Script to configure the Minecraft server as a systemd service  
├── s3upload.sh                  # Script to upload Minecraft server files to AWS S3  
├── config.yaml                  # Configuration file for server settings  
└── minecraftserver.service      # Systemd service file for managing the Minecraft server  

- firsttime_install.sh:
    - Purpose: This is the main setup script for initializing a Minecraft server on an AWS Ubuntu instance. It installs necessary dependencies (Java, YQ, AWS CLI), downloads the Minecraft server files from an S3 bucket, and configures the server directory.
    - Usage: sudo bash firsttime_install.sh
    - Key Features:
        * Installs Java, YQ, unzip, and AWS CLI.
        * Downloads the latest server version from S3.
        * Configures directory ownership and permissions.
        * Sets up the server as a systemd service.
- firsttime_spigot.sh:
    - Purpose: This script is used to set up a Spigot Minecraft server. It installs Spigot-specific dependencies and uses Spigot’s BuildTools to build the Spigot server .jar file.
    - Usage: sudo bash firsttime_spigot.sh
    - Key Features:
        * Installs Java JDK 21 for building Spigot.
        * Downloads Spigot's BuildTools and compiles Spigot.
- firsttime_forge.sh:
    * Purpose: This script installs Forge for modded Minecraft servers. It downloads the Forge installer, runs the installation, and configures the server to use the Forge .jar file.
    * Usage: sudo bash firsttime_forge.sh
    * Key Features:
        * Downloads and installs Forge.
        * Cleans up installer files and configures the Minecraft server directory for Forge.
- mcserver_systemd.sh:
    * Purpose: This script creates or updates the systemd service file for the Minecraft server, enabling the server to start automatically and be managed via systemctl. It dynamically configures the service based on the .jar file (Spigot, Forge, or Vanilla) and memory settings in config.yaml.
    * Usage: sudo bash mcserver_systemd.sh [spigot]
    * Key Features:
        * Dynamically sets the server’s memory allocation and the Minecraft .jar file to use.
        * Creates or updates the systemd service file for the server.
        * Enables the service and starts the Minecraft server.
- s3upload.sh:
    * Purpose: This script uploads the Minecraft server files to an AWS S3 bucket for backup purposes. It allows you to upload the server to a versioned folder and update the latest backup.
    * Usage: bash s3upload.sh [version_name]
    * Key Features:
        * Syncs the current mcserver/ directory to a timestamped version folder in S3.
        * Updates the latest backup on S3.
- config.yaml:
    * Purpose: This YAML file contains key configuration details for the server setup, such as the path to the server directory (ubuntu_path), memory allocation, and the default .jar file to run.
    * Usage: Modify the values in this file to fit your server environment and setup (e.g., memory, directory paths).