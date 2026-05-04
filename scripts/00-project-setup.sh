#!/bin/bash
#############################################
# Project Setup Script
# Run this to set up the entire project
#############################################

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "3-Tier Java Application CI/CD Setup"
echo "========================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

# Check Git
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed"
    exit 1
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "⚠️  Docker is not installed (required for local testing)"
fi

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "⚠️  AWS CLI is not installed (required for AWS setup)"
fi

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo "⚠️  kubectl is not installed (required for Kubernetes deployment)"
fi

echo "✅ Prerequisites check complete"
echo ""

# Create required directories
echo "Creating project structure..."
mkdir -p logs
mkdir -p reports
mkdir -p backups
mkdir -p config

echo "✅ Project structure created"
echo ""

# Display next steps
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Next Steps:"
echo "1. Review documentation:"
echo "   - README.md - Project overview"
echo "   - docs/INFRASTRUCTURE-SETUP.md - Create AWS infrastructure"
echo "   - docs/JENKINS-SETUP.md - Configure Jenkins"
echo "   - docs/SONARQUBE-SETUP.md - Configure SonarQube"
echo "   - docs/NEXUS-SETUP.md - Configure Nexus"
echo "   - docs/EKS-DEPLOYMENT.md - Deploy to EKS"
echo ""
echo "2. Update configuration:"
echo "   - Edit docs/CONFIGURATION.md with your values"
echo ""
echo "3. Execute setup scripts:"
echo "   - scripts/01-install-java.sh"
echo "   - scripts/02-setup-jenkins.sh"
echo "   - scripts/03-install-docker-jenkins.sh"
echo "   - scripts/04-setup-sonarqube.sh"
echo "   - scripts/05-setup-nexus.sh"
echo "   - scripts/06-eks-cluster-setup.sh"
echo ""
echo "4. Configure and deploy:"
echo "   - Follow Jenkins pipeline guide"
echo "   - Deploy to EKS using Kubernetes manifests"
echo ""
echo "Happy CI/CD-ing! 🚀"
