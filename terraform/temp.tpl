#!/bin/bash
# Update package list and upgrade packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y git nginx certbot python3-certbot-nginx curl

# Install Docker
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

docker --version
git --version
# Install Node.js 18 and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

node -v
npm -v

# Install PM2 globally
sudo npm install -g pm2

# Create the /srv directory if it doesn't exist
sudo mkdir -p /srv/
cd /srv/

# Clone the Strapi template repository
git clone https://github.com/harshit3355/Strapi_template.git
sudo mv Strapi_template/ strapi/
cd strapi/
sudo chmod +x env_generator.sh
./env_generator.sh

# Build Docker image
sudo docker build -t harshit3355/peer:latest .

# Log in to Docker Hub using environment variables
echo "${docker_hub_password}" | sudo docker login -u "${docker_hub_username}" --password-stdin

# Push Docker image to Docker Hub
sudo docker push harshit3355/peer:latest

# Create Docker volume for Strapi data
sudo docker volume create strapi-data

# Run Strapi container with mounted volume
sudo docker run -d --name strapi-container -p 1337:1337 -v strapi-data:/srv/strapi/public/uploads harshit3355/peer:latest

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

# Obtain SSL certificate using Let's Encrypt
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
