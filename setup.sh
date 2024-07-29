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

# Add ec2-user to docker group
sudo usermod -aG docker ec2-user

# Clone the Kutt repository
cd /app_docker_storage
git clone https://github.com/thedevs-network/kutt
cd kutt

# Download the .docker.env and rename it to .env
cp .docker.env .env

# Install Docker Compose
wget https://github.com/docker/compose/releases/download/v2.23.1/docker-compose-linux-x86_64
sudo install docker-compose-linux-x86_64 /usr/local/bin/docker-compose

# Start the Kutt application
docker-compose up
