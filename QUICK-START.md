# Quick Start Guide for 3-Tier Java Application CI/CD Pipeline

## 🚀 5-Minute Quick Start

### Prerequisites
- AWS Account with EC2 permissions
- Local machine with: Git, Docker, AWS CLI, kubectl, eksctl

### Step 1: Clone and Setup (5 min)
```bash
cd Project-2
bash scripts/00-project-setup.sh
```

### Step 2: Create Infrastructure (15 min)
```bash
# Create 3 EC2 instances manually or via CloudFormation
# Follow: docs/INFRASTRUCTURE-SETUP.md
```

### Step 3: Install Basic Tools (10 min)
```bash
# SSH to each instance
bash scripts/01-install-java.sh
```

### Step 4: Setup Jenkins (5 min)
```bash
# SSH to Jenkins instance
bash scripts/02-setup-jenkins.sh
bash scripts/03-install-docker-jenkins.sh

# Access: http://JENKINS_IP:8080
```

### Step 5: Setup SonarQube (2 min)
```bash
# SSH to SonarQube instance
bash scripts/04-setup-sonarqube.sh

# Access: http://SONARQUBE_IP:9000
```

### Step 6: Setup Nexus (2 min)
```bash
# SSH to Nexus instance
bash scripts/05-setup-nexus.sh

# Access: http://NEXUS_IP:8081
```

### Step 7: Create EKS Cluster (20 min)
```bash
bash scripts/06-eks-cluster-setup.sh
```

### Step 8: Deploy Application
```bash
kubectl apply -f kubernetes/
```

### Step 9: Verify Deployment
```bash
kubectl get svc ekart -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
# Access application via LoadBalancer endpoint
```

---

## 📚 Full Documentation

For detailed setup and configuration, see:

1. **[INFRASTRUCTURE-SETUP.md](docs/INFRASTRUCTURE-SETUP.md)** - AWS infrastructure
2. **[JENKINS-SETUP.md](docs/JENKINS-SETUP.md)** - Jenkins configuration
3. **[SONARQUBE-SETUP.md](docs/SONARQUBE-SETUP.md)** - SonarQube setup
4. **[NEXUS-SETUP.md](docs/NEXUS-SETUP.md)** - Nexus configuration
5. **[JENKINS-PIPELINE.md](docs/JENKINS-PIPELINE.md)** - Pipeline stages
6. **[EKS-DEPLOYMENT.md](docs/EKS-DEPLOYMENT.md)** - Kubernetes deployment
7. **[SECURITY-BEST-PRACTICES.md](docs/SECURITY-BEST-PRACTICES.md)** - Security guidelines

---

## 🔑 Key Credentials to Save

1. Jenkins initial admin password
2. SonarQube admin password
3. Nexus admin password
4. Database password
5. Docker Hub credentials
6. AWS IAM credentials

⚠️ Store all credentials securely!

---

## ✅ Verification Checklist

- [ ] All EC2 instances created and running
- [ ] Java installed on all servers
- [ ] Jenkins accessible and initialized
- [ ] SonarQube running and configured
- [ ] Nexus running and configured
- [ ] EKS cluster created
- [ ] Kubernetes manifests deployed
- [ ] Application accessible via LoadBalancer
- [ ] Monitoring and logging configured

---

## 🐛 Troubleshooting

### Common Issues:

1. **Can't access Jenkins**: Check security group allows port 8080
2. **SonarQube not starting**: Check Docker and memory requirements
3. **EKS deployment fails**: Verify kubeconfig and IAM permissions
4. **LoadBalancer not accessible**: Check security groups and network policies

See [INFRASTRUCTURE-SETUP.md](docs/INFRASTRUCTURE-SETUP.md#troubleshooting) for detailed troubleshooting.

---

## 📞 Support

For issues or questions:
1. Check relevant documentation file
2. Review Jenkins build logs
3. Check container logs: `docker logs <container-name>`
4. Check Kubernetes logs: `kubectl logs <pod-name>`

---

## 🔐 Security First!

⚠️ **Important**: Never commit credentials to Git!

- Use Jenkins Credentials Store
- Use Kubernetes Secrets
- Use AWS Secrets Manager
- Use environment variables

See [SECURITY-BEST-PRACTICES.md](docs/SECURITY-BEST-PRACTICES.md) for detailed guidelines.

---

## 🎯 Next Steps After Setup

1. **Configure Jenkins Pipeline**:
   - Create Jenkins job with Jenkinsfile
   - Configure GitHub webhook
   - Set up notifications

2. **Test End-to-End**:
   - Make code change
   - Commit and push to GitHub
   - Verify pipeline execution
   - Check deployment in EKS

3. **Production Hardening**:
   - Enable HTTPS
   - Set up monitoring and alerts
   - Configure auto-scaling
   - Set up backup and recovery
   - Enable security scanning

4. **Team Onboarding**:
   - Document all configurations
   - Create runbooks for operations
   - Train team on CI/CD process
   - Set up on-call procedures

---

**Happy Deploying! 🚀**
