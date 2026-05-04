# 3-Tier Java Application CI/CD Pipeline Project

## 📌 Architecture Overview

This project implements a complete CI/CD pipeline for a 3-tier Java application using industry-standard tools:

```
Developer → GitHub → Jenkins → SonarQube → Nexus → Docker → DockerHub → EKS Deployment
```

### Architecture Components:
- **Frontend Tier**: NGINX (Ingress Controller)
- **Application Tier**: Java Spring Boot (Running on EKS)
- **Data Tier**: MySQL Database

### CI/CD Tools:
- **Jenkins**: Build automation & orchestration
- **SonarQube**: Code quality analysis & security scanning
- **Nexus**: Artifact repository management
- **Docker**: Container creation & management
- **EKS**: Kubernetes deployment platform
- **OWASP Dependency-Check**: Security vulnerability scanning

---

## 🚀 Project Structure

```
Project-2/
├── infrastructure/          # AWS EC2 setup & infrastructure as code
├── jenkins/                # Jenkins configuration & pipelines
├── kubernetes/             # K8s manifests for EKS deployment
├── application/            # Sample Java application
├── docker/                 # Dockerfile & container configs
├── scripts/                # Automation & setup scripts
├── docs/                   # Documentation & guides
└── README.md              # This file
```

---

## 📋 Prerequisites

### Local Machine
- AWS Account with appropriate permissions
- AWS CLI configured
- kubectl installed
- Docker installed (optional, for local testing)

### Infrastructure Requirements
- 3 × Ubuntu 20.04 EC2 instances (t2.medium)
  - Jenkins Server
  - SonarQube Server
  - Nexus Server

---

## 🔧 Quick Start Guide

### Step 1: Infrastructure Setup
```bash
cd infrastructure/
# Review and execute EC2 instance creation scripts
# Modify variables as per your AWS region and requirements
```

### Step 2: Install Prerequisites on All Servers
```bash
# Execute on each EC2 instance
bash scripts/01-install-java.sh
```

### Step 3: Jenkins Setup
```bash
# Execute on Jenkins server
bash scripts/02-setup-jenkins.sh
bash scripts/03-install-docker-jenkins.sh
```

### Step 4: SonarQube Setup
```bash
# Execute on SonarQube server
bash scripts/04-setup-sonarqube.sh
```

### Step 5: Nexus Setup
```bash
# Execute on Nexus server
bash scripts/05-setup-nexus.sh
```

### Step 6: Jenkins Configuration
1. Access Jenkins at `http://<Jenkins-IP>:8080`
2. Install required plugins (see docs/JENKINS-SETUP.md)
3. Configure global tools (JDK, Maven, Sonar Scanner)
4. Set up credentials
5. Configure SonarQube integration

### Step 7: Create EKS Cluster
```bash
cd infrastructure/
bash eks-cluster-setup.sh
```

### Step 8: Deploy Application
Create Jenkins pipeline using Jenkinsfile and deploy to EKS

---

## 📚 Documentation

Detailed step-by-step guides are available in the `docs/` folder:

1. [INFRASTRUCTURE-SETUP.md](docs/INFRASTRUCTURE-SETUP.md) - EC2 & AWS setup
2. [JENKINS-SETUP.md](docs/JENKINS-SETUP.md) - Jenkins installation & configuration
3. [SONARQUBE-SETUP.md](docs/SONARQUBE-SETUP.md) - SonarQube installation
4. [NEXUS-SETUP.md](docs/NEXUS-SETUP.md) - Nexus installation
5. [JENKINS-PIPELINE.md](docs/JENKINS-PIPELINE.md) - Pipeline stages & flow
6. [EKS-DEPLOYMENT.md](docs/EKS-DEPLOYMENT.md) - Kubernetes deployment
7. [SECURITY-BEST-PRACTICES.md](docs/SECURITY-BEST-PRACTICES.md) - Security guidelines

---

## 🔐 Security Best Practices

⚠️ **IMPORTANT**: Never hardcode sensitive information in:
- Jenkinsfile
- pom.xml
- GitHub repositories
- Environment variables

✅ **Use Instead**:
- Jenkins Credentials System
- AWS IAM Roles
- Kubernetes Secrets
- HashiCorp Vault (for production)

---

## 📊 Pipeline Stages

1. **Clone Code** - Fetch from GitHub
2. **Build** - Maven compilation
3. **SonarQube Analysis** - Code quality & security scan
4. **Dependency Check** - Vulnerability detection
5. **Package Artifact** - Create JAR/WAR
6. **Upload to Nexus** - Store artifact
7. **Build Docker Image** - Create container image
8. **Push to DockerHub** - Store container image
9. **Deploy to EKS** - Deploy to Kubernetes cluster

---

## 🔍 Monitoring & Verification

### Jenkins
- Access: `http://<Jenkins-IP>:8080`
- Monitor builds and logs in real-time

### SonarQube
- Access: `http://<SonarQube-IP>:9000`
- Default credentials: `admin / admin`
- Review code quality metrics and vulnerabilities

### Nexus
- Access: `http://<Nexus-IP>:8081`
- Manage artifacts and repositories

### EKS Cluster
```bash
# View deployed applications
kubectl get pods -A

# Check services
kubectl get svc -A

# View logs
kubectl logs -n <namespace> <pod-name>
```

---

## 🐛 Troubleshooting

### Jenkins Connection Issues
- Check security groups allow port 8080
- Verify Jenkins service is running: `sudo systemctl status jenkins`

### SonarQube Not Accessible
- Check container is running: `docker ps | grep sonarqube`
- Check logs: `docker logs <container-id>`

### Nexus Access Problems
- Verify container status: `docker ps | grep nexus`
- Get default password from container

### EKS Deployment Failures
- Check cluster status: `eksctl get clusters`
- Verify IAM permissions
- Review Kubernetes manifest syntax

---

## 📞 Support & References

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Nexus Repository Documentation](https://help.sonatype.com/repomanager3)
- [Docker Documentation](https://docs.docker.com/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)

---

## 📝 License

This project is provided as-is for educational purposes.

---

## 🔄 Next Steps

After successful deployment:
1. Push changes to GitHub
2. Jenkins will automatically trigger the pipeline
3. Monitor the build progress in Jenkins dashboard
4. Verify deployment in EKS cluster
5. Access application via LoadBalancer endpoint

**Happy CI/CD-ing! 🎉**
