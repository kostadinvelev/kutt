#!/bin/bash

# Create Docker storage
sudo echo 'type=83' | sudo sfdisk /dev/xvdb
sudo mkfs.xfs /dev/xvdb1
sudo mkdir /app_docker_storage
sudo mount /dev/xvdb1 /app_docker_storage

# Install Docker
sudo yum update -y
sudo yum install -y docker git

# Configure Docker to use the new storage directory
echo "Configuring Docker storage..."
sudo mkdir -p /etc/docker
echo '{
  "data-root": "/app_docker_storage"
}' | sudo tee /etc/docker/daemon.json

# Enable and start Docker
sudo systemctl enable --now docker

# Add ec2-user to docker group
sudo usermod -aG docker ec2-user
git clone https://github.com/thedevs-network/kutt
cd kutt
cp .docker.env .env
wget https://github.com/docker/compose/releases/download/v2.23.1/docker-compose-linux-x86_64
sudo install docker-compose-linux-x86_64 /usr/local/bin/docker-compose
docker-compose up