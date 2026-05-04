#!/bin/bash
#############################################
# Install and Setup Nexus 3 (Docker)
# Run on: Nexus Server
#############################################

set -e

echo "========================================="
echo "Setting up Nexus 3..."
echo "========================================="

# Update package lists
sudo apt update -y

# Install Docker
sudo apt install docker.io -y

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Run Nexus container
echo "Pulling Nexus Docker image..."
sudo docker pull sonatype/nexus3:latest

echo "Starting Nexus container..."
sudo docker run -d \
  -p 8081:8081 \
  --name nexus \
  sonatype/nexus3:latest

# Wait for Nexus to start
echo "Waiting for Nexus to initialize (this may take 2-3 minutes)..."
sleep 60

echo ""
echo "========================================="
echo "✅ Nexus installed successfully!"
echo "========================================="
echo "Access Nexus at: http://$(hostname -I | awk '{print $1}'):8081"
echo ""
echo "To get the initial admin password, run:"
echo "  sudo docker exec nexus cat /nexus-data/admin.password"
echo ""
echo "Verify container is running:"
sudo docker ps | grep nexus
