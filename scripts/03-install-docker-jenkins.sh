#!/bin/bash
#############################################
# Install Docker and Configure Jenkins User
# Run on: Jenkins Server
#############################################

set -e

echo "========================================="
echo "Installing Docker on Jenkins Server..."
echo "========================================="

# Update package lists
sudo apt update -y

# Install Docker
sudo apt install docker.io -y

# Add Jenkins user to Docker group
sudo usermod -aG docker jenkins

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Restart Jenkins to apply group changes
echo "Restarting Jenkins service..."
sudo systemctl restart jenkins

# Wait for restart
sleep 5

echo ""
echo "========================================="
echo "✅ Docker installed successfully!"
echo "========================================="
echo "Jenkins user has been added to docker group"
echo ""
echo "Verify Docker installation:"
docker --version
