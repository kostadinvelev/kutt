#!/bin/bash

LOGFILE="/tmp/setup.log"

exec > >(tee -i $LOGFILE)
exec 2>&1

# Create Docker storage
echo "Creating Docker storage..."
echo 'type=83' | sudo sfdisk /dev/xvdb
sudo mkfs.xfs /dev/xvdb1
sudo mkdir /app_docker_storage
sudo mount /dev/xvdb1 /app_docker_storage

# Install Docker and Git
echo "Installing Docker and Git..."
sudo yum update -y
sudo yum install -y docker git

# Configure Docker to use the new storage
echo "Configuring Docker storage..."
sudo mkdir -p /etc/docker
echo '{"data-root": "/app_docker_storage"}' | sudo tee /etc/docker/daemon.json

# Enable and start Docker service
echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Add ec2-user to docker group
echo "Adding ec2-user to docker group..."
sudo usermod -aG docker ec2-user

# Clone the Kutt repository
echo "Cloning Kutt repository..."
cd /app_docker_storage
sudo -u ec2-user git clone https://github.com/thedevs-network/kutt
cd kutt

# Download the .docker.env and rename it to .env
echo "Downloading .docker.env..."
sudo -u ec2-user wget https://raw.githubusercontent.com/thedevs-network/kutt/develop/.docker.env -O .env

# Install Docker Compose
echo "Installing Docker Compose..."
wget https://github.com/docker/compose/releases/download/v2.23.1/docker-compose-linux-x86_64
sudo install docker-compose-linux-x86_64 /usr/local/bin/docker-compose

# Ensure permissions are set correctly
echo "Setting permissions..."
sudo chown -R ec2-user:docker /app_docker_storage

# Start the Kutt application
echo "Starting Kutt application..."
sudo -u ec2-user docker-compose up -d

# Check Docker status
echo "Checking Docker status..."
sudo systemctl status docker

echo "Setup script completed."
