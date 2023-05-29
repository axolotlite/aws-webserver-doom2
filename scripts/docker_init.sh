#!/bin/bash
sudo apt update -y
sudo apt install docker.io docker-compose -y
git clone https://github.com/antyung88/docker-game-doom2.git
cd docker-game-doom2
docker-compose up -d
sudo ufw allow 8000