#!/bin/bash

# Update package list
sudo apt-get update -y
sudo apt-get install -y git

sudo apt-get install -y curl
git --version
# Install Node.js 18 and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

node -v
npm -v

# Install PM2 globally
sudo npm install -g pm2

pwd
ls -la
# Create the /srv directory if it doesn't exist
mkdir -p /home/ubuntu/srv
pwd
ls -la
sudo chown -R ubuntu:ubuntu /home/ubuntu/srv
pwd
ls -la
cd /home/ubuntu/srv/
pwd
ls -la

# Create a new Strapi project in the /srv directory
# echo -e "skip\n" | npx create-strapi-app strapi --quickstart --no-run

# cd strapi

git clone https://github.com/harshit3355/Strapi_template.git
pwd
ls -la
sudo mv Strapi_template/ strapi/
cd strapi/
pwd
ls -la
sudo chmod +x env_generator.sh
./env_generator.sh

npm install 
pm2 start npm --name "strapi" -- run develop
