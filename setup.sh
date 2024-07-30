#!/bin/bash

# Create Docker storage
echo test > /tmp/test
sudo echo 'type=83' | sudo sfdisk /dev/xvdb
sudo mkfs.xfs /dev/xvdb1
sudo mkdir /app_docker_storage
sudo mount /dev/xvdb1 /app_docker_storage

# Install Docker and Git
sudo yum update -y
sudo yum install -y docker git

# Configure Docker to use the new storage
sudo sed -ie 's%DOCKER_STORAGE_OPTIONS=%DOCKER_STORAGE_OPTIONS="-g /app_docker_storage"%g' /etc/sysconfig/docker-storage

# Enable and start Docker service
sudo systemctl enable --now docker

# Wait a bit to ensure Docker is fully started
sleep 10

# Add ec2-user to docker group
sudo usermod -aG docker ec2-user

# Clone the Kutt repository
cd /app_docker_storage
sudo -u ec2-user git clone https://github.com/thedevs-network/kutt
cd kutt

# Download the .docker.env and rename it to .env
sudo -u ec2-user cp .docker.env .env

# Install Docker Compose
wget https://github.com/docker/compose/releases/download/v2.23.1/docker-compose-linux-x86_64
sudo install docker-compose-linux-x86_64 /usr/local/bin/docker-compose

# Ensure permissions are set correctly
sudo chown -R ec2-user:docker /app_docker_storage

# Start the Kutt application
sudo -u ec2-user docker-compose up -d
