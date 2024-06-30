#!/bin/bash
# Update package list
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y git nginx certbot python3-certbot-nginx curl

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
cd /srv/
pwd
ls -la

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

# Configure NGINX
cat <<EOF | sudo tee /etc/nginx/sites-available/default
server {
    listen 80;
    server_name admin.technobizz.biz;

    location / {
        proxy_pass http://localhost:1337;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Restart NGINX to apply the configuration
sudo systemctl restart nginx

sudo certbot --nginx -d admin.technobizz.biz --non-interactive --agree-tos -m harshitnagila555@gmail.com

# Enable SSL in NGINX
cat <<EOF | sudo tee /etc/nginx/sites-available/default
server {
    listen 80;
    server_name admin.technobizz.biz;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name admin.technobizz.biz;

    ssl_certificate /etc/letsencrypt/live/admin.technobizz.biz/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/admin.technobizz.biz/privkey.pem;

    location / {
        proxy_pass http://localhost:1337;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Restart NGINX to apply the SSL configuration
sudo systemctl restart nginx
