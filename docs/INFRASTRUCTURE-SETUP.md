# Infrastructure Setup Guide

## Overview
This guide covers setting up the AWS infrastructure required for the 3-Tier Java Application CI/CD Pipeline.

---

## Prerequisites
- AWS Account with appropriate IAM permissions
- AWS CLI installed and configured
- Key pair created in your AWS region

---

## Step 1: Launch EC2 Instances

### Create 3 Ubuntu 20.04 EC2 Instances (t2.medium)

#### Using AWS Management Console:
1. Navigate to **EC2 → Instances → Launch Instances**
2. Select **Ubuntu 20.04 LTS** (AMI)
3. Choose instance type: **t2.medium**
4. Configure:
   - **Number of instances**: 3
   - **VPC**: Default or custom VPC
   - **Subnet**: Public subnet (for internet access)
   - **Auto-assign Public IP**: Enable
5. Add storage: **30 GB (gp3)**
6. Add tags:
   - Instance 1: Name = `Jenkins-Server`
   - Instance 2: Name = `SonarQube-Server`
   - Instance 3: Name = `Nexus-Server`
7. Configure Security Group:
   - Allow SSH (port 22) from your IP
   - Allow HTTP (port 80)
   - Allow HTTPS (port 443)
   - Allow Jenkins (port 8080)
   - Allow SonarQube (port 9000)
   - Allow Nexus (port 8081)
8. Review and launch

#### Instance Security Group Rules:
```
Inbound Rules:
- SSH (22): 0.0.0.0/0 (or restrict to your IP)
- HTTP (80): 0.0.0.0/0
- HTTPS (443): 0.0.0.0/0
- Jenkins (8080): 0.0.0.0/0
- SonarQube (9000): 0.0.0.0/0
- Nexus (8081): 0.0.0.0/0

Outbound Rules:
- All traffic allowed
```

---

## Step 2: Connect to Instances

### Using SSH:
```bash
# Replace <PATH-TO-KEY-PAIR> and <PUBLIC-IP> with your values
ssh -i <PATH-TO-KEY-PAIR>.pem ubuntu@<PUBLIC-IP>
```

### Using AWS Systems Manager Session Manager:
```bash
# Install Session Manager plugin on your local machine
# Then use:
aws ssm start-session --target i-xxxxxxxxxxxxx
```

---

## Step 3: Initial Setup on All Instances

### Connect to each instance and run:
```bash
# Update system packages
sudo apt update -y
sudo apt upgrade -y

# Install essential tools
sudo apt install -y curl wget git vim htop

# Install Java 17
sudo apt install openjdk-17-jre-headless -y
java -version
```

---

## Step 4: Jenkins Instance Setup

### On Jenkins instance:
```bash
# Run setup scripts
bash scripts/02-setup-jenkins.sh
bash scripts/03-install-docker-jenkins.sh

# Verify Jenkins is running
sudo systemctl status jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Access Jenkins:
```
URL: http://<JENKINS-PUBLIC-IP>:8080
Initial Admin Password: (from above command)
```

---

## Step 5: SonarQube Instance Setup

### On SonarQube instance:
```bash
# Run setup script
bash scripts/04-setup-sonarqube.sh

# Verify SonarQube container
sudo docker ps | grep sonarqube

# Check logs
sudo docker logs sonarqube
```

### Access SonarQube:
```
URL: http://<SONARQUBE-PUBLIC-IP>:9000
Default Credentials: admin / admin
(You will be prompted to change password on first login)
```

---

## Step 6: Nexus Instance Setup

### On Nexus instance:
```bash
# Run setup script
bash scripts/05-setup-nexus.sh

# Verify Nexus container
sudo docker ps | grep nexus

# Get initial admin password
sudo docker exec nexus cat /nexus-data/admin.password
```

### Access Nexus:
```
URL: http://<NEXUS-PUBLIC-IP>:8081
Username: admin
Password: (from above command)
```

---

## Step 7: Create EKS Cluster

### Prerequisites:
- Install `eksctl`: https://eksctl.io/introduction/installation/
- Install `kubectl`: https://kubernetes.io/docs/tasks/tools/
- Configure AWS CLI credentials

### Create Cluster:
```bash
# Create EKS cluster
eksctl create cluster \
  --name my-cluster \
  --region ap-south-1 \
  --nodegroup-name my-nodes \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 3 \
  --nodes-max 10

# Update kubeconfig
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name my-cluster

# Verify cluster
kubectl get nodes
kubectl get pods -A
```

### Create OIDC Provider (for IAM roles):
```bash
eksctl utils associate-iam-oidc-provider \
  --region ap-south-1 \
  --cluster my-cluster \
  --approve
```

---

## Step 8: Install Ingress Controller (Optional)

### Install NGINX Ingress Controller:
```bash
# Add Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install NGINX Ingress Controller
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer
```

---

## Step 9: Verify All Services

### Jenkins:
```bash
curl http://<JENKINS-PUBLIC-IP>:8080
```

### SonarQube:
```bash
curl http://<SONARQUBE-PUBLIC-IP>:9000
```

### Nexus:
```bash
curl http://<NEXUS-PUBLIC-IP>:8081
```

### EKS Cluster:
```bash
kubectl cluster-info
kubectl get nodes
```

---

## Cost Optimization Tips

1. **Develop/Test Instances**: Use `t2.micro` or `t2.small` for testing
2. **Stop Instances**: Stop instances during non-working hours
3. **Use Reserved Instances**: For production 24/7 usage
4. **Delete Resources**: Clean up when project is complete:
   ```bash
   # Delete EKS cluster
   eksctl delete cluster --name my-cluster --region ap-south-1

   # Terminate EC2 instances
   # Use AWS Console or CLI
   ```

---

## Troubleshooting

### EC2 Connection Issues:
- Verify security group allows SSH (port 22)
- Check key pair permissions: `chmod 400 key.pem`
- Ensure instance has public IP assigned

### Service Not Accessible:
- Check security group rules
- Verify service is running: `sudo systemctl status <service>`
- Check logs: `docker logs <container-name>`

### EKS Cluster Issues:
- Verify IAM permissions
- Check cluster status: `eksctl get cluster --region ap-south-1`
- Review cluster events: `kubectl get events -A`

---

## Next Steps
1. Configure Jenkins plugins and integrations (see JENKINS-SETUP.md)
2. Set up SonarQube with Jenkins (see SONARQUBE-SETUP.md)
3. Configure Nexus for artifact management (see NEXUS-SETUP.md)
4. Create Jenkins pipeline (see JENKINS-PIPELINE.md)
5. Deploy application to EKS (see EKS-DEPLOYMENT.md)
