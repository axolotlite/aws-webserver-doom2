#!/bin/bash
sudo apt update
curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
sudo bash /tmp/nodesource_setup.sh
sudo apt install nodejs p7zip-full -y
wget https://${bucket_name}.s3.amazonaws.com/build.zip
7z x build.zip
sudo npm install -g serve
export PORT=${default_port}
sudo ufw allow ${default_port}
serve -s build