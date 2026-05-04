#!/bin/bash
#############################################
# Install and Setup Jenkins
# Run on: Jenkins Server
#############################################

set -e

echo "========================================="
echo "Setting up Jenkins..."
echo "========================================="

# Update package lists
sudo apt update -y

# Add Jenkins repository key
wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add Jenkins repository
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update and install Jenkins
sudo apt update -y
sudo apt install jenkins -y

# Start Jenkins service
echo "Starting Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Wait for Jenkins to start
echo "Waiting for Jenkins to initialize..."
sleep 10

# Get initial admin password
JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

echo ""
echo "========================================="
echo "✅ Jenkins installed successfully!"
echo "========================================="
echo "Access Jenkins at: http://$(hostname -I | awk '{print $1}'):8080"
echo "Initial Admin Password: $JENKINS_PASSWORD"
echo "========================================="
echo ""
echo "Next Steps:"
echo "1. Open Jenkins in browser"
echo "2. Enter the initial admin password"
echo "3. Install suggested plugins"
echo "4. Create first admin user"
echo "5. Install additional plugins as needed"
