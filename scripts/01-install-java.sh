#!/bin/bash
#############################################
# Install Java 17 JRE on Ubuntu Server
# Run on: All servers (Jenkins, SonarQube, Nexus)
#############################################

set -e

echo "========================================="
echo "Installing Java 17 JRE..."
echo "========================================="

# Update package lists
sudo apt update -y

# Install OpenJDK 17 JRE
sudo apt install openjdk-17-jre-headless -y

# Verify installation
echo ""
echo "========================================="
echo "Java Version:"
echo "========================================="
java -version

echo ""
echo "✅ Java 17 JRE installed successfully!"
