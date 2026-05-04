# Jenkins Setup and Configuration Guide

## Overview
Complete guide to set up and configure Jenkins for CI/CD pipeline.

---

## Step 1: Verify Jenkins Installation

```bash
# Check Jenkins service status
sudo systemctl status jenkins

# View Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Get initial admin password
JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo "Jenkins Admin Password: $JENKINS_PASSWORD"
```

---

## Step 2: Access Jenkins Dashboard

1. Open browser and go to: `http://<JENKINS-IP>:8080`
2. Enter the **Initial Admin Password** (from above)
3. Click **Continue**

---

## Step 3: Install Plugins

### Required Plugins

Go to **Dashboard → Manage Jenkins → Manage Plugins → Available**

Search and install the following plugins:

#### Build and Compilation
- [ ] Maven Integration
- [ ] Pipeline Maven Integration

#### Code Quality
- [ ] SonarQube Scanner
- [ ] CheckStyle
- [ ] FindBugs
- [ ] PMD

#### Security and Vulnerability
- [ ] OWASP Dependency-Check
- [ ] Snyk Security

#### Container and Deployment
- [ ] Docker
- [ ] Docker Pipeline
- [ ] Amazon EC2 Container Registry (ECR) Plugin
- [ ] Kubernetes
- [ ] Kubernetes CLI

#### Artifact Repository
- [ ] Nexus Artifact Uploader
- [ ] Nexus Platform Plugin

#### Pipeline and Automation
- [ ] Pipeline
- [ ] Pipeline: Declarative
- [ ] Pipeline: Scripted
- [ ] Timestamper
- [ ] Log Parser

#### Source Control
- [ ] Git
- [ ] GitHub
- [ ] GitHub Integration
- [ ] SSH Agent

#### Notifications
- [ ] Email Extension
- [ ] Slack Notification

### Installation Steps:
1. Click checkbox next to each plugin name
2. Click **Install without restart** or **Download now and install after restart**
3. Wait for installation to complete
4. Restart Jenkins if necessary: `Manage Jenkins → System Setup → Restart Jenkins`

---

## Step 4: Global Tool Configuration

### Go to: **Manage Jenkins → Global Tool Configuration**

#### Configure JDK:
1. Click **Add JDK**
2. Set Name: `JDK-17`
3. Select: **Install automatically**
4. Choose JDK version: `OpenJDK 17` (or use local installation)
5. Click **Save**

#### Configure Maven:
1. Click **Add Maven**
2. Set Name: `Maven-3.8.3`
3. Select: **Install automatically**
4. Choose Maven version: `3.8.3`
5. Click **Save**

#### Configure SonarQube Scanner:
1. Click **Add SonarQube Scanner**
2. Set Name: `SonarQube-Scanner`
3. Select: **Install automatically**
4. Choose version: `Latest`
5. Click **Save**

#### Configure OWASP Dependency-Check:
1. Click **Add Dependency-Check**
2. Set Name: `dependency-check`
3. Select: **Install automatically**
4. Click **Save**

#### Configure Docker:
1. Click **Add Docker**
2. Set Name: `Docker`
3. Select: **Install from docker.com**
4. Latest version should be auto-selected
5. Click **Save**

---

## Step 5: Configure System Settings

### Go to: **Manage Jenkins → Configure System**

#### Configure Jenkins URL:
- Set **Jenkins URL** to: `http://<JENKINS-IP>:8080/`

#### Email Notification (Optional):
1. Scroll to **Email Notification**
2. Set SMTP server: `smtp.gmail.com` (or your email provider)
3. Set SMTP port: `587`
4. Enable **Use SMTP Authentication**
5. Add email credentials in Jenkins Credentials
6. Enable **Use TLS**
7. Set **Default user email suffix**: `@yourcompany.com`

#### GitHub Integration (Optional):
1. Add GitHub Server
2. Set API URL: `https://api.github.com`
3. Add GitHub credentials in Jenkins Credentials

#### Slack Integration (Optional):
1. Get Slack webhook URL
2. Add to Slack token in Jenkins Credentials
3. Configure Slack workspace

---

## Step 6: Create Jenkins Credentials

### Go to: **Manage Jenkins → Manage Credentials → Jenkins (Global)**

#### Add Credentials:

##### 1. SonarQube Token
1. Click **Add Credentials**
2. Kind: **Secret text**
3. Secret: `<Your-SonarQube-Token>`
4. ID: `sonar-token`
5. Click **Create**

##### 2. Docker Hub Credentials
1. Click **Add Credentials**
2. Kind: **Username with password**
3. Username: `<Your-Docker-Username>`
4. Password: `<Your-Docker-Token/Password>`
5. ID: `docker-credentials`
6. Click **Create**

##### 3. Nexus Credentials
1. Click **Add Credentials**
2. Kind: **Username with password**
3. Username: `admin`
4. Password: `<Nexus-Admin-Password>`
5. ID: `nexus-credentials`
6. Click **Create**

##### 4. GitHub Credentials (if using GitHub)
1. Click **Add Credentials**
2. Kind: **Username with password** (or SSH key)
3. Username: `<Your-GitHub-Username>`
4. Password: `<Your-Personal-Access-Token>`
5. ID: `github-credentials`
6. Click **Create**

##### 5. AWS Credentials (for EKS)
1. Click **Add Credentials**
2. Kind: **AWS Credentials**
3. Access Key ID: `<Your-AWS-Access-Key>`
4. Secret Access Key: `<Your-AWS-Secret-Key>`
5. ID: `aws-credentials`
6. Click **Create**

---

## Step 7: Configure SonarQube Integration

### Go to: **Manage Jenkins → Configure System**

#### SonarQube Servers:
1. Scroll to **SonarQube Servers**
2. Click **Add**
3. Set **Name**: `SonarQube`
4. Set **Server URL**: `http://<SONARQUBE-IP>:9000`
5. Set **Server authentication token**: Select `sonar-token` credential
6. Click **Save**

---

## Step 8: Configure Maven Settings

### Go to: **Manage Jenkins → Managed Files**

1. Click **Create new file**
2. Type: **GlobalMavenSettings**
3. ID: `maven-settings`
4. Name: `Global Maven Settings`
5. Content:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
          http://maven.apache.org/xsd/settings-1.0.0.xsd">
    
    <servers>
        <server>
            <id>maven-releases</id>
            <username>admin</username>
            <password>${NEXUS_PASSWORD}</password>
        </server>
        <server>
            <id>maven-snapshots</id>
            <username>admin</username>
            <password>${NEXUS_PASSWORD}</password>
        </server>
    </servers>
    
    <mirrors>
        <mirror>
            <id>nexus</id>
            <mirrorOf>*</mirrorOf>
            <url>http://<NEXUS-IP>:8081/repository/maven-public/</url>
        </mirror>
    </mirrors>
    
</settings>
```

6. Click **Save**

---

## Step 9: Create Credentials for Maven Settings

1. Go to **Manage Jenkins → Manage Credentials**
2. Add credential:
   - Kind: **Username with password**
   - Username: `admin`
   - Password: `<Nexus-Admin-Password>`
   - ID: `nexus-settings`
   - Click **Create**

---

## Step 10: Configure Docker Integration

### On Jenkins Server:
```bash
# Verify docker is installed
docker --version

# Verify jenkins user can run docker
sudo usermod -aG docker jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# Test docker access
sudo -u jenkins docker ps
```

---

## Step 11: Create First Pipeline Job

### Go to: **Dashboard → New Item**

1. Enter job name: `Sample-Pipeline`
2. Select: **Pipeline**
3. Click **OK**

#### Pipeline Configuration:
1. Select: **Pipeline script from SCM**
2. SCM: **Git**
3. Repository URL: `https://github.com/your-repo/Project-2.git`
4. Branch: `*/main` or `*/master`
5. Script Path: `jenkins/Jenkinsfile`
6. Click **Save**

---

## Step 12: Test Pipeline Execution

1. Click **Build Now**
2. Monitor build progress in **Console Output**
3. Verify stages complete successfully

---

## Troubleshooting

### Jenkins Won't Start
```bash
sudo systemctl status jenkins
sudo tail -f /var/log/jenkins/jenkins.log
```

### Plugin Installation Issues
- Clear Jenkins cache: `sudo rm -rf /var/lib/jenkins/pluginManager.xml`
- Restart Jenkins: `sudo systemctl restart jenkins`

### Docker Permission Denied
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### SonarQube Connection Error
- Verify SonarQube is running: `curl http://<SONAR-IP>:9000`
- Check network connectivity between servers
- Verify security group rules

### Nexus Not Reachable
- Verify Nexus container: `docker ps | grep nexus`
- Check port binding: `docker port nexus`

---

## Security Best Practices

1. **Change Default Credentials**: Always change default admin password
2. **Enable Authentication**: Ensure Jenkins requires login
3. **Disable Anonymous Access**: Go to **Manage Jenkins → Configure Global Security**
4. **Use HTTPS**: Configure SSL/TLS for Jenkins
5. **Manage Credentials**: Never hardcode passwords in Jenkinsfile
6. **Install Security Plugins**: Enable CSRF protection, script approval
7. **Regular Updates**: Keep Jenkins and plugins updated

---

## Next Steps

1. Configure SonarQube (see SONARQUBE-SETUP.md)
2. Configure Nexus (see NEXUS-SETUP.md)
3. Create Jenkins pipeline (see JENKINS-PIPELINE.md)
4. Set up EKS deployment (see EKS-DEPLOYMENT.md)
