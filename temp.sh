#!/bin/bash

wget https://piston-data.mojang.com/v1/objects/145ff0858209bcfc164859ba735d4199aafa1eea/server.jar
cp server.jar minecraft_server.1.20.6.jar
rm server.jar
screen -S minecraft_server -t minecraft

java -Xmx1750M -Xms1750M -jar minecraft_server.1.20.6.jar nogui
sed -i 's/false/true/g' eula.txt
java -Xmx1750M -Xms1750M -jar minecraft_server.1.20.6.jar nogui


sudo aws s3 cp s3://megabyttenpersonalmcserverbackups/latest ~/mcserver/ --recursive