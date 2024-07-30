#!/bin/bash

# Create Docker storage
echo test > /tmp/test
sudo echo 'type=83' | sudo sfdisk /dev/xvdh
sudo mkfs.xfs /dev/xvdh1
sudo mkdir /mbition_docker
sudo mount /dev/xvdh1 /mbition_docker

# Install Docker
sudo yum update -y
sudo yum install -y docker git

# Set Docker Storage to /k8s directory
sudo sed -ie 's%DOCKER_STORAGE_OPTIONS=%DOCKER_STORAGE_OPTIONS="-g /mbition_docker"%g' /etc/sysconfig/docker-storage

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