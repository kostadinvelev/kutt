#!/bin/bash

# Enable error reporting and logging
set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting setup script..."

# Create Docker storage
echo "Creating test file..."
echo test > /tmp/test

echo "Partitioning EBS volume..."
sudo parted -s /dev/xvdb mklabel gpt
sudo parted -s /dev/xvdb mkpart primary xfs 0% 100%

echo "Formatting EBS partition..."
sudo mkfs.xfs /dev/xvdb1

echo "Creating mount point..."
sudo mkdir -p /app_docker_storage

echo "Mounting EBS volume..."
sudo mount /dev/xvdb1 /app_docker_storage

# Install Docker
echo "Updating system..."
sudo yum update -y

echo "Installing Docker..."
sudo amazon-linux-extras install docker -y

# Set Docker Storage to /app_docker_storage directory
echo "Configuring Docker storage..."
sudo mkdir -p /etc/docker
echo '{"data-root": "/app_docker_storage"}' | sudo tee /etc/docker/daemon.json

# Enable and start Docker
echo "Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Add ec2-user to docker group
echo "Adding ec2-user to docker group..."
sudo usermod -aG docker ec2-user

echo "Cloning Kutt repository..."
git clone https://github.com/thedevs-network/kutt
cd kutt

echo "Copying environment file..."
cp .docker.env .env

echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Starting Kutt application..."
docker-compose up -d

echo "Setup script completed."