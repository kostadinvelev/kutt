#!/bin/bash

set -e

# Create Docker storage
echo "Creating Docker storage..."
echo 'type=83' | sudo sfdisk /dev/xvdb
sudo mkfs.xfs /dev/xvdb1
sudo mkdir /app_docker_storage
sudo mount /dev/xvdb1 /app_docker_storage

# Verify if the directory is mounted
if mountpoint -q /app_docker_storage; then
    echo "/app_docker_storage is mounted."
else
    echo "Failed to mount /app_docker_storage."
    exit 1
fi

# Install Docker and Git
echo "Installing Docker and Git..."
sudo yum update -y
sudo yum install -y docker git

# Configure Docker to use the new storage directory
echo "Configuring Docker storage..."
sudo mkdir -p /etc/docker
echo '{
  "data-root": "/app_docker_storage"
}' | sudo tee /etc/docker/daemon.json

# Verify if daemon.json is created
if [ -f /etc/docker/daemon.json ]; then
    echo "/etc/docker/daemon.json created successfully."
else
    echo "Failed to create /etc/docker/daemon.json."
    exit 1
fi

# Enable and start Docker
echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Verify if Docker service is running
if systemctl is-active --quiet docker; then
    echo "Docker service is running."
else
    echo "Docker service failed to start."
    exit 1
fi

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

# Start the Kutt application
echo "Starting Kutt application..."
sudo -u ec2-user docker-compose up -d

# Verify Docker containers are running
if sudo -u ec2-user docker ps; then
    echo "Kutt application is running."
else
    echo "Failed to start Kutt application."
    exit 1
fi

echo "Setup script completed successfully."
