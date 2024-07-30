#!/bin/bash

# Create Docker storage
echo test > /tmp/test
sudo echo 'type=83' | sudo sfdisk /dev/xvdb
sudo mkfs.xfs /dev/xvdb1
sudo mkdir /app_docker_storage
sudo mount /dev/xvdb1 /app_docker_storage

# Docker full setup
sudo yum update -y
sudo yum install -y git
sudo amazon-linux-extras install docker
echo '{"data-root": "/app_docker_storage"}' | sudo tee /etc/docker/daemon.json > /dev/null
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone and start Kutt
git clone https://github.com/thedevs-network/kutt
cd kutt
cp .docker.env .env
docker-compose up -d

