#!/bin/bash
#############################################
# Install and Setup SonarQube (Docker)
# Run on: SonarQube Server
#############################################

set -e

echo "========================================="
echo "Setting up SonarQube..."
echo "========================================="

# Update package lists
sudo apt update -y

# Install Docker
sudo apt install docker.io -y

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Pull and run SonarQube
echo "Pulling SonarQube Docker image..."
sudo docker pull sonarqube:latest

echo "Starting SonarQube container..."
sudo docker run -d \
  -p 9000:9000 \
  --name sonarqube \
  sonarqube:latest

# Wait for SonarQube to start
echo "Waiting for SonarQube to initialize (this may take 1-2 minutes)..."
sleep 30

echo ""
echo "========================================="
echo "✅ SonarQube installed successfully!"
echo "========================================="
echo "Access SonarQube at: http://$(hostname -I | awk '{print $1}'):9000"
echo "Default credentials: admin / admin"
echo ""
echo "⚠️  First login will require password change"
echo ""
echo "Verify container is running:"
sudo docker ps | grep sonarqube
