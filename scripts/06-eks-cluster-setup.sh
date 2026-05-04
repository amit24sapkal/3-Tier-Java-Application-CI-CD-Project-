#!/bin/bash
#############################################
# EKS Cluster Setup Script
# Creates and configures EKS cluster
#############################################

set -e

# Configuration
CLUSTER_NAME="my-cluster"
REGION="ap-south-1"
NODE_TYPE="t3.medium"
NODES_MIN="3"
NODES_MAX="10"
NODEGROUP_NAME="my-nodes"

echo "========================================="
echo "Creating EKS Cluster..."
echo "========================================="

# Check if eksctl is installed
if ! command -v eksctl &> /dev/null; then
    echo "eksctl is not installed. Installing..."
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
fi

# Create EKS cluster
echo "Creating EKS cluster: $CLUSTER_NAME in region: $REGION"
eksctl create cluster \
    --name $CLUSTER_NAME \
    --region $REGION \
    --nodegroup-name $NODEGROUP_NAME \
    --node-type $NODE_TYPE \
    --nodes $NODES_MIN \
    --nodes-min $NODES_MIN \
    --nodes-max $NODES_MAX \
    --managed \
    --with-oidc \
    --enable-ssm \
    --version 1.27

# Update kubeconfig
echo "Updating kubeconfig..."
aws eks update-kubeconfig \
    --region $REGION \
    --name $CLUSTER_NAME

# Verify cluster
echo ""
echo "========================================="
echo "✅ EKS Cluster Created Successfully!"
echo "========================================="
echo ""
echo "Cluster Information:"
eksctl get cluster --name=$CLUSTER_NAME --region=$REGION

echo ""
echo "Nodes:"
kubectl get nodes

echo ""
echo "Next Steps:"
echo "1. Deploy Kubernetes manifests:"
echo "   kubectl apply -f kubernetes/"
echo "2. Verify deployment:"
echo "   kubectl get pods"
echo "3. Get LoadBalancer IP:"
echo "   kubectl get svc ekart"
