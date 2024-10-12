#!/bin/bash
sudo apt update

# Installing no GUI Java runtime
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt install openjdk-21-jre-headless -y

# Installing AWS so we can pull server from S3
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
rm -rf awscliv2.zip
sudo ./aws/install