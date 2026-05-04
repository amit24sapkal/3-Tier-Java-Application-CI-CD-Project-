# Project Configuration Template

Use this file to document your specific configuration values.

---

## AWS Configuration

```
Region: ap-south-1
AWS Account ID: __________________
```

---

## EC2 Instances

### Jenkins Server
```
Instance ID: __________________
Public IP: __________________
Private IP: __________________
Username: ubuntu
Key Pair: __________________
```

### SonarQube Server
```
Instance ID: __________________
Public IP: __________________
Private IP: __________________
Username: ubuntu
Key Pair: __________________
```

### Nexus Server
```
Instance ID: __________________
Public IP: __________________
Private IP: __________________
Username: ubuntu
Key Pair: __________________
```

---

## Jenkins Configuration

```
URL: http://__________________:8080
Admin Username: admin
Admin Password: __________________
Initial Admin Password: __________________
```

---

## SonarQube Configuration

```
URL: http://__________________:9000
Username: admin
Password: __________________
SonarQube Token: __________________
Project Key: ekart
```

---

## Nexus Configuration

```
URL: http://__________________:8081
Admin Username: admin
Admin Password: __________________
Jenkins User: jenkins
Jenkins Password: __________________
```

---

## Docker Hub

```
Username: __________________
Token/Password: __________________
Repository: __________________/ekart
```

---

## GitHub Repository

```
Repository URL: https://github.com/amit24sapkal/3-Tier-Java-Application-CI-CD-Project-.git
Branch: __________________
GitHub Token: __________________
```

---

## EKS Cluster

```
Cluster Name: my-cluster
Region: ap-south-1
Node Type: t3.medium
Initial Nodes: 3
Max Nodes: 10
```

---

## Database Configuration

```
Host: __________________
Port: 3306
Username: ekart_user
Password: __________________
Database Name: ekart_db
Root Password: __________________
```

---

## Email Configuration (Jenkins)

```
SMTP Server: __________________
SMTP Port: 587
From Email: __________________
Email Username: __________________
Email Password: __________________
```

---

## AWS IAM Credentials

```
Access Key ID: __________________
Secret Access Key: __________________
ARN: __________________
```

---

## SSL/TLS Certificates (for production)

```
Certificate File: __________________
Key File: __________________
Chain File: __________________
```

---

## Monitoring and Logging

```
CloudWatch Log Group: __________________
SNS Topic for Alerts: __________________
Alert Email: __________________
```

---

## Important Endpoints

```
Jenkins: http://JENKINS_IP:8080
SonarQube: http://SONARQUBE_IP:9000
Nexus: http://NEXUS_IP:8081
Application LoadBalancer: http://LOAD_BALANCER_DNS
```

---

## Useful Commands

```bash
# SSH to Jenkins
ssh -i <key>.pem ubuntu@<JENKINS_IP>

# SSH to SonarQube
ssh -i <key>.pem ubuntu@<SONARQUBE_IP>

# SSH to Nexus
ssh -i <key>.pem ubuntu@<NEXUS_IP>

# Access EKS cluster
aws eks update-kubeconfig --name my-cluster --region ap-south-1
kubectl get nodes

# Get Nexus password
docker exec nexus cat /nexus-data/admin.password

# Get Jenkins password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

## Security Credentials Checklist

⚠️ **IMPORTANT**: Store all credentials securely!

- [ ] Jenkins Credentials created for Nexus
- [ ] Jenkins Credentials created for SonarQube
- [ ] Jenkins Credentials created for Docker Hub
- [ ] Jenkins Credentials created for GitHub
- [ ] Jenkins Credentials created for AWS
- [ ] Database password changed from default
- [ ] Admin passwords changed from defaults
- [ ] SSH keys securely stored
- [ ] Jenkins initial admin password stored

---

## Deployment Checklist

- [ ] All EC2 instances created and running
- [ ] Java installed on all servers
- [ ] Jenkins installed and configured
- [ ] SonarQube running and accessible
- [ ] Nexus running and accessible
- [ ] EKS cluster created
- [ ] kubectl configured to access cluster
- [ ] Kubernetes manifests created
- [ ] Docker image built and pushed
- [ ] Application deployed to EKS
- [ ] Application accessible via LoadBalancer
- [ ] Monitoring and logging configured

---

## Maintenance Tasks

Regular maintenance schedule:

- [ ] Weekly: Check Jenkins build logs
- [ ] Weekly: Monitor cluster resources
- [ ] Monthly: Review security logs
- [ ] Monthly: Update dependencies
- [ ] Quarterly: Security audit
- [ ] Quarterly: Disaster recovery test
