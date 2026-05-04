# SonarQube Setup and Configuration Guide

## Overview
Complete guide to set up and configure SonarQube for code quality analysis.

---

## Step 1: Verify SonarQube Installation

```bash
# Check if container is running
sudo docker ps | grep sonarqube

# View container logs
sudo docker logs sonarqube

# Wait for startup (check logs for "SonarQube is up")
```

---

## Step 2: Access SonarQube Dashboard

1. Open browser: `http://<SONARQUBE-IP>:9000`
2. Default credentials:
   - Username: `admin`
   - Password: `admin`
3. Click **Log in**
4. You will be prompted to **Change Password** - Do this on first login!

---

## Step 3: Create SonarQube Token

### For Jenkins Integration:

1. Go to **Profile (top-right corner) → My Account → Security**
2. Click **Generate Tokens**
3. Name: `Jenkins-Token`
4. Type: Select **Global Analysis Token** or **Project Analysis Token**
5. Click **Generate**
6. **Copy the token** (save this securely)
7. Click **Done**

**Store this token in Jenkins Credentials!**

---

## Step 4: Create Projects in SonarQube

### Manual Project Creation:

1. Click **Create project**
2. Enter **Project key**: `ekart` (must be unique)
3. Enter **Project name**: `Ekart Application`
4. Click **Set Up**
5. Select **Jenkins** as CI/CD tool
6. Follow the setup wizard

### Via Jenkins Pipeline:

SonarQube projects can be auto-created when first analysis is run.

---

## Step 5: Configure Quality Gates

### Default Quality Gate:

1. Go to **Quality Gates**
2. Click **Sonar way** (default)
3. Review conditions:
   - Reliability: Grade A
   - Security: Grade A
   - Maintainability: Grade A
   - Code Coverage: >80%
   - Duplicated Lines: <3%

### Create Custom Quality Gate:

1. Click **Create**
2. Name: `Project-Quality-Gate`
3. Add conditions:
   - Coverage: >70%
   - Critical Issues: 0
   - Major Issues: <5
   - Code Smells: <50
   - Bugs: 0
4. Click **Save**

### Assign Quality Gate to Project:

1. Go to **Projects → Select Your Project**
2. Click **Project Settings → Quality Gate**
3. Select your quality gate
4. Click **Save**

---

## Step 6: Configure Issues and Rules

### Profile Configuration:

1. Go to **Quality Profiles**
2. Search for your profile (e.g., `Java`)
3. Click to edit
4. Adjust rules as needed:
   - Enable/Disable rules
   - Set severity levels
   - Configure rule parameters

### Create Custom Profile:

1. Click **Create**
2. Name: `Project-Custom-Profile`
3. Language: `Java`
4. Parent: `Sonar way`
5. Click **Create**
6. Assign to project in **Project Settings**

---

## Step 7: Webhook Integration with Jenkins

### Set Up Webhook:

1. Go to **Administration → Configuration → Webhooks**
2. Click **Create**
3. Name: `Jenkins-Webhook`
4. URL: `http://JENKINS-IP:8080/sonarqube-webhook/`
5. Select events:
   - [ ] Quality Gate
6. Click **Create**

### Jenkins Configuration:

In Jenkins, install **SonarQube Scanner for Jenkins** plugin:
1. This allows Jenkins to receive SonarQube analysis results
2. Pipeline can fail if quality gate fails

---

## Step 8: Configure Authentication

### LDAP Integration (Optional):

1. Go to **Administration → Configuration → Authentication**
2. Select **LDAP**
3. Configure LDAP server details
4. Test connection
5. Click **Save**

### OAuth Integration (Optional):

1. Go to **Administration → Configuration → Authentication**
2. Select OAuth provider (GitHub, Google, etc.)
3. Add OAuth credentials
4. Click **Save**

---

## Step 9: Configure Email Notifications (Optional)

1. Go to **Administration → Configuration → Email**
2. Enter:
   - SMTP Server: `smtp.gmail.com`
   - Port: `587`
   - From: `noreply@company.com`
   - Enable TLS
3. Enter credentials
4. Click **Save & Test**

---

## Step 10: Security Configuration

### Security Best Practices:

1. **Change Admin Password**:
   - Profile → My Account → Security → Change Password

2. **Disable Guest Account**:
   - Administration → Security → Users
   - Disable/Remove guest user

3. **Manage Permissions**:
   - Administration → Security → Global Permissions
   - Define role-based permissions

4. **Force Authentication**:
   - Administration → Configuration → Security
   - Require authentication for project analysis

---

## Step 11: Configure SonarQube in Jenkins

### Jenkins Pipeline Configuration:

In your Jenkinsfile, add SonarQube analysis step:

```groovy
stage('SonarQube Analysis') {
    steps {
        script {
            withSonarQubeEnv('SonarQube') {
                sh '''
                    mvn sonar:sonar \
                    -Dsonar.projectKey=ekart \
                    -Dsonar.projectName="Ekart Application" \
                    -Dsonar.sources=src/main/java \
                    -Dsonar.tests=src/test/java
                '''
            }
        }
    }
}
```

---

## Step 12: Monitor SonarQube Analysis Results

### Dashboard:

1. Click on project name
2. View:
   - Overall Code Quality
   - Security Issues
   - Code Smells
   - Bugs
   - Code Coverage
   - Duplications

### Issue Details:

1. Click on issue type
2. View issue details:
   - Severity level
   - File and line number
   - Detailed explanation
   - How to fix

### Trending:

1. Click **Trends** to see:
   - Code quality progression over time
   - Issue count trends
   - Coverage improvements

---

## Step 13: Integration with IDE (Optional)

### SonarLint Plugin:

Install SonarLint in your IDE (VS Code, IntelliJ, etc.):

1. This provides real-time quality feedback
2. Bind to SonarQube project for consistent rules
3. Fix issues before commit

---

## Step 14: Backup SonarQube Configuration

```bash
# Backup SonarQube data directory
sudo docker exec sonarqube tar czf - /opt/sonarqube/data | \
    gzip > sonarqube-backup-$(date +%Y%m%d).tar.gz

# Backup database (if using PostgreSQL)
# Configure in SonarQube settings
```

---

## Troubleshooting

### SonarQube Won't Start
```bash
sudo docker logs sonarqube
sudo docker restart sonarqube
```

### Analysis Fails
- Check SonarQube is running: `curl http://SONAR-IP:9000`
- Verify credentials in Jenkins
- Check network connectivity
- Review Jenkins build logs

### Quality Gate Not Working
- Verify webhook is configured
- Check Jenkins receives webhook calls
- Verify quality gate is assigned to project

### Memory Issues
```bash
# If SonarQube runs out of memory:
sudo docker stop sonarqube
sudo docker run -d -p 9000:9000 \
    -e SONARQUBE_JAVA_OPTS="-Xmx1024m" \
    sonarqube:latest
```

---

## Performance Tuning

### Increase Analysis Performance:

1. **Increase Memory**:
```bash
docker stop sonarqube
docker run -d -p 9000:9000 \
    -e SONARQUBE_JAVA_OPTS="-Xmx2048m -Xms1024m" \
    -e SONARQUBE_ES_JAVA_OPTS="-Xmx2048m -Xms2048m" \
    sonarqube:latest
```

2. **Use PostgreSQL Database**:
   - Better performance than embedded H2
   - Configure in `sonar.properties`

3. **Enable Parallel Analysis**:
   - Use multiple analysis threads
   - Configure in project settings

---

## Next Steps

1. Configure Jenkins integration (see JENKINS-SETUP.md)
2. Create analysis rules and profiles
3. Set up quality gates
4. Configure webhook integration
5. Run first analysis via Jenkins pipeline
