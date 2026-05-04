# Jenkins CI/CD Pipeline Guide

## Overview
Complete guide to understand and execute the CI/CD pipeline stages.

---

## Pipeline Flow

```
Developer Code Commit
        ↓
Clone Code from GitHub
        ↓
Maven Build
        ↓
SonarQube Code Analysis
        ↓
OWASP Dependency Check
        ↓
Package Artifact (JAR/WAR)
        ↓
Upload to Nexus Repository
        ↓
Build Docker Image
        ↓
Push to DockerHub
        ↓
Deploy to EKS Cluster
        ↓
Verify Deployment
        ↓
✅ Pipeline Complete
```

---

## Pipeline Stages Detailed

### Stage 1: Clone Code
**Purpose**: Fetch source code from GitHub repository

```groovy
stage('Clone Code') {
    steps {
        script {
            checkout scm
        }
    }
}
```

**What happens**:
- Jenkins connects to GitHub
- Clones the repository
- Checks out specific branch
- All subsequent stages work with this code

**Verify**:
```bash
# In Jenkins workspace
ls -la
cat .git/config
```

---

### Stage 2: Build
**Purpose**: Compile Java code and create artifact

```groovy
stage('Build') {
    steps {
        script {
            sh 'mvn clean package -DskipTests'
        }
    }
}
```

**What happens**:
- Runs Maven build
- Compiles Java source code
- Resolves dependencies from Nexus
- Creates JAR/WAR file in `target/` directory
- `clean`: Removes previous build artifacts
- `package`: Creates distribution package
- `-DskipTests`: Skips unit tests (can be removed for full testing)

**Verify**:
```bash
# Check if JAR was created
ls -la target/*.jar

# JAR file size
du -sh target/ekart-app-1.0.0.jar
```

---

### Stage 3: SonarQube Analysis
**Purpose**: Analyze code quality and security vulnerabilities

```groovy
stage('SonarQube Analysis') {
    steps {
        script {
            withSonarQubeEnv('SonarQube') {
                sh '''
                    mvn sonar:sonar \
                    -Dsonar.projectKey=ekart \
                    -Dsonar.sources=src/main/java \
                    -Dsonar.tests=src/test/java
                '''
            }
        }
    }
}
```

**What happens**:
- Scans code for bugs, vulnerabilities, code smells
- Measures code coverage
- Detects duplicated code
- Reports metrics to SonarQube
- Optional: Waits for quality gate result

**SonarQube Metrics**:
- **Bugs**: Code errors
- **Vulnerabilities**: Security issues
- **Code Smells**: Code quality issues
- **Coverage**: Percentage of code tested
- **Duplications**: Duplicated code blocks

**Verify**:
- Open SonarQube dashboard: `http://SONARQUBE_IP:9000`
- Check project analysis results
- Review issue details

---

### Stage 4: Dependency Check
**Purpose**: Scan for security vulnerabilities in dependencies

```groovy
stage('Dependency Check') {
    steps {
        script {
            sh '''
                dependency-check.sh \
                --project "ekart" \
                --scan . \
                --format JSON \
                --out ./reports/
            '''
        }
    }
}
```

**What happens**:
- Scans all project dependencies
- Checks for known vulnerabilities (CVEs)
- Generates security report
- Identifies outdated libraries

**Verify**:
- Check generated report: `reports/dependency-check-report.json`
- Review vulnerabilities in Jenkins logs
- Address critical vulnerabilities

---

### Stage 5: Upload Artifact to Nexus
**Purpose**: Store compiled artifact in Nexus repository

```groovy
stage('Upload Artifact to Nexus') {
    steps {
        script {
            sh '''
                mvn deploy \
                -DskipTests \
                -Dmaven.wagon.http.ssl.insecure=true
            '''
        }
    }
}
```

**What happens**:
- Uses credentials from Jenkins Credentials
- Uploads JAR/WAR to Nexus repository
- Stores artifact metadata
- Makes artifact available for deployment

**Verify**:
```bash
# Access Nexus
http://NEXUS_IP:8081
# Navigate to maven-releases repository
# Verify artifact exists
```

---

### Stage 6: Build Docker Image
**Purpose**: Create Docker container image

```groovy
stage('Build Docker Image') {
    steps {
        script {
            sh '''
                docker build -t ${DOCKER_IMAGE}:${VERSION} .
                docker tag ${DOCKER_IMAGE}:${VERSION} ${DOCKER_IMAGE}:latest
            '''
        }
    }
}
```

**What happens**:
- Builds Docker image from Dockerfile
- Uses multi-stage build for optimization
- Tags image with version and latest
- Creates lightweight production image

**Verify**:
```bash
# List Docker images
docker images | grep ekart

# Inspect image
docker history ekart:1.0

# Check image size
docker images ekart
```

---

### Stage 7: Push to DockerHub
**Purpose**: Upload Docker image to DockerHub registry

```groovy
stage('Push to DockerHub') {
    steps {
        script {
            sh '''
                echo ${DOCKER_CREDENTIALS_PSW} | \
                docker login -u ${DOCKER_CREDENTIALS_USR} --password-stdin
                docker push ${DOCKER_IMAGE}:${VERSION}
                docker push ${DOCKER_IMAGE}:latest
                docker logout
            '''
        }
    }
}
```

**What happens**:
- Authenticates with DockerHub
- Pushes image to registry
- Makes image available for deployment
- Logs out after completion

**Verify**:
```bash
# Access DockerHub
docker image ls | grep ekart
docker pull ekart:latest
```

---

### Stage 8: Deploy to EKS
**Purpose**: Deploy application to Kubernetes cluster

```groovy
stage('Deploy to EKS') {
    steps {
        script {
            sh '''
                aws eks update-kubeconfig \
                --name my-cluster \
                --region ap-south-1
                
                sed -i "s|IMAGE_TAG|${DOCKER_IMAGE}:${VERSION}|g" \
                kubernetes/deployment.yaml
                
                kubectl apply -f kubernetes/
                kubectl rollout status deployment/ekart
            '''
        }
    }
}
```

**What happens**:
- Configures kubectl to access EKS cluster
- Updates Kubernetes manifest with new image
- Applies manifests (deployment, service, etc.)
- Waits for rollout to complete
- Performs rolling update with zero downtime

**Verify**:
```bash
# Check pods
kubectl get pods -l app=ekart

# Check services
kubectl get svc ekart

# View deployment status
kubectl rollout status deployment/ekart

# Check logs
kubectl logs -l app=ekart

# Get LoadBalancer IP
kubectl get svc ekart -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

---

### Stage 9: Verify Deployment
**Purpose**: Confirm application is running correctly

```groovy
stage('Verify Deployment') {
    steps {
        script {
            sh '''
                # Check pod status
                kubectl get pods -l app=ekart
                
                # Check service status
                kubectl get svc ekart
                
                # Get LoadBalancer endpoint
                kubectl get svc ekart -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
            '''
        }
    }
}
```

**What happens**:
- Verifies all pods are running
- Checks service accessibility
- Retrieves LoadBalancer endpoint
- Confirms deployment success

---

## Post-Build Actions

### Success Actions:
- Send success notification
- Update deployment status

### Failure Actions:
- Send failure notification
- Trigger rollback (optional)
- Notify development team

### Always Actions:
- Archive test results
- Clean up Docker resources
- Archive security reports

---

## Environment Variables

```groovy
environment {
    APP_NAME = "ekart"
    VERSION = "${BUILD_ID}"
    DOCKER_REGISTRY = "docker.io"
    DOCKER_IMAGE = "${DOCKER_REGISTRY}/<USERNAME>/ekart"
    NEXUS_URL = "http://NEXUS_IP:8081"
    SONAR_HOST = "http://SONARQUBE_IP:9000"
}
```

---

## Manual Trigger vs Automated

### Manual Trigger:
1. Click **Build Now** in Jenkins dashboard
2. Monitor build progress in Console Output

### Automatic Trigger (Webhook):
1. Configure GitHub webhook to Jenkins
2. Every code push triggers pipeline
3. Results visible in GitHub commit status

---

## Testing the Pipeline

### Local Testing (Before Pipeline):

```bash
# Build locally
mvn clean package

# Run unit tests
mvn test

# Run SonarQube analysis
mvn sonar:sonar -Dsonar.host.url=http://localhost:9000 \
-Dsonar.login=admin

# Build Docker image
docker build -t ekart:test .

# Run Docker container
docker run -p 8080:8080 ekart:test

# Test health endpoint
curl http://localhost:8080/api/health
```

---

## Pipeline Monitoring

### Jenkins Dashboard:
- View build history
- Check console output
- Monitor build duration
- Track build trends

### Blue Ocean:
- Modern pipeline visualization
- Real-time log streaming
- Better failure diagnostics

### CloudWatch (AWS):
- Monitor EKS cluster resources
- Track application logs
- Set up alarms

---

## Troubleshooting Pipeline Failures

### Build Fails:
1. Check console output for errors
2. Verify dependencies are available
3. Check Maven configuration

### SonarQube Fails:
1. Verify SonarQube is running
2. Check credentials
3. Verify project configuration

### Docker Build Fails:
1. Check Dockerfile syntax
2. Verify base image is available
3. Check Docker daemon is running

### Deployment Fails:
1. Verify EKS cluster is running
2. Check credentials and permissions
3. Verify image is available in DockerHub
4. Check resource quotas in cluster

---

## Pipeline Metrics

### Key Metrics to Track:
- **Build Duration**: Optimize pipeline performance
- **Failure Rate**: Identify reliability issues
- **Code Coverage**: Ensure quality
- **Deployment Frequency**: Monitor release cadence
- **Lead Time**: Reduce time from code to production

---

## Optimization Tips

1. **Parallel Builds**: Run independent stages in parallel
2. **Caching**: Cache dependencies to speed up builds
3. **Docker Layer Caching**: Optimize Docker builds
4. **Resource Limits**: Allocate appropriate resources
5. **Timeout Configuration**: Set reasonable timeouts

---

## Next Steps

1. Execute first pipeline run
2. Monitor build logs
3. Verify application in EKS
4. Set up monitoring and alerts
5. Configure notifications
6. Optimize pipeline performance
