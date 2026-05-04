# Security Best Practices Guide

## Overview
Security guidelines for CI/CD pipeline, cloud infrastructure, and application deployment.

---

## 1. Credentials Management

### ❌ NEVER DO:

```groovy
// DON'T hardcode credentials
stage('Build') {
    steps {
        sh '''
            mvn deploy \
            -DnexusUsername=admin \
            -DnexusPassword=password123  // NEVER!
        '''
    }
}
```

```xml
<!-- DON'T hardcode in pom.xml -->
<server>
    <id>nexus</id>
    <username>admin</username>
    <password>password123</password>  <!-- NEVER! -->
</server>
```

### ✅ DO THIS:

```groovy
// Use Jenkins Credentials
stage('Build') {
    steps {
        withCredentials([
            usernamePassword(
                credentialsId: 'nexus-credentials',
                usernameVariable: 'NEXUS_USER',
                passwordVariable: 'NEXUS_PASS'
            )
        ]) {
            sh '''
                mvn deploy \
                -DnexusUsername=$NEXUS_USER \
                -DnexusPassword=$NEXUS_PASS
            '''
        }
    }
}
```

### Credential Storage:

1. **Jenkins Credentials**:
   - Store in Jenkins Credentials store
   - Use environment variables in pipeline
   - Rotate credentials regularly

2. **AWS Secrets Manager**:
```bash
# Store secret
aws secretsmanager create-secret \
  --name ekart/db-password \
  --secret-string "password123"

# Retrieve secret
aws secretsmanager get-secret-value \
  --secret-id ekart/db-password
```

3. **HashiCorp Vault** (Production):
```bash
# Store secret
vault kv put secret/ekart/db password=secret123

# Retrieve secret
vault kv get secret/ekart/db
```

---

## 2. Network Security

### Security Groups Configuration:

```bash
# Only expose necessary ports
# Jenkins: 8080 (internally), allow from CI/CD runners
# SonarQube: 9000 (internally)
# Nexus: 8081 (internally)
# EKS: 443 (Kubernetes API, restrict to admin IPs)
# Application: 80/443 (public via LoadBalancer)

# Example: Restrict Jenkins to specific IP
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxx \
  --protocol tcp \
  --port 8080 \
  --cidr 203.0.113.0/32  # Your IP
```

### Kubernetes Network Policies:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ekart-network-policy
spec:
  podSelector:
    matchLabels:
      app: ekart
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: mysql
    ports:
    - protocol: TCP
      port: 3306
```

---

## 3. Container Security

### Dockerfile Security:

```dockerfile
# ✅ DO: Use specific base image version
FROM openjdk:17-jdk-slim

# ❌ DON'T: Use latest (unpredictable)
# FROM openjdk:latest

# ✅ DO: Create non-root user
RUN useradd -m -u 1000 appuser
USER appuser

# ✅ DO: Remove unnecessary packages
RUN apt-get update && apt-get install -y \
    only-needed-packages \
    && rm -rf /var/lib/apt/lists/*

# ✅ DO: Set resource limits
COPY --from=builder /app/target/app.jar app.jar
ENTRYPOINT ["java", "-Xmx512m", "-jar", "app.jar"]
```

### Image Scanning:

```bash
# Scan with Trivy (vulnerability scanner)
trivy image docker.io/username/ekart:latest

# Scan with Snyk
snyk container test docker.io/username/ekart:latest

# Sign images with Cosign
cosign sign --key cosign.key docker.io/username/ekart:latest
```

---

## 4. Kubernetes Security

### Pod Security Standards:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ekart
spec:
  template:
    spec:
      # ✅ Run as non-root
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault
      
      containers:
      - name: ekart
        # ✅ Set resource limits
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        # ✅ Security context
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
            - ALL
        
        # ✅ Health checks
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 30
        
        readinessProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
```

### RBAC Configuration:

```yaml
# Least privilege access
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ekart-role
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

---

## 5. Application Security

### OWASP Top 10 Prevention:

1. **Injection Attacks**:
   - Use parameterized queries
   - Validate all inputs
   - Use prepared statements

2. **Authentication**:
   - Use strong password policies
   - Implement MFA
   - Use OAuth/OIDC

3. **Sensitive Data Exposure**:
   - Use HTTPS/TLS
   - Encrypt sensitive data
   - Avoid logging passwords

4. **Broken Access Control**:
   - Implement proper authorization
   - Use least privilege principle
   - Regular access reviews

5. **Security Misconfiguration**:
   - Disable unnecessary services
   - Set security headers
   - Regular security patches

### Maven Dependency Management:

```xml
<!-- Use OWASP Dependency-Check -->
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>8.0.0</version>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>
    </configuration>
</plugin>

<!-- Keep dependencies updated -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <version>3.0.0</version> <!-- Keep up to date -->
</dependency>
```

---

## 6. Database Security

### MySQL Best Practices:

```bash
# Create limited-privilege user
CREATE USER 'ekart_user'@'%' IDENTIFIED BY 'strong_password_123';
GRANT SELECT, INSERT, UPDATE, DELETE ON ekart_db.* TO 'ekart_user'@'%';
FLUSH PRIVILEGES;

# Never use root user for application
# Rotate credentials regularly
# Use SSL for connections
```

### Kubernetes Secrets:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ekart-db-secret
type: Opaque
stringData:
  username: ekart_user
  password: strong_password_123  # Use Sealed Secrets in production
---
# Use in deployment
env:
- name: DB_USER
  valueFrom:
    secretKeyRef:
      name: ekart-db-secret
      key: username
```

---

## 7. CI/CD Pipeline Security

### Jenkins Security:

```groovy
// ✅ DO: Use credentials
withCredentials([
    file(credentialsId: 'aws-credentials', variable: 'AWS_CREDS')
]) {
    sh 'source $AWS_CREDS && aws s3 ls'
}

// ❌ DON'T: Print secrets
echo "Password: ${PASSWORD}"  // Don't do this!

// ✅ DO: Use ****** masking
echo "Password: ****"
```

### Git Security:

```bash
# Use SSH keys instead of HTTPS
git clone git@github.com:user/repo.git

# Sign commits
git config user.signingkey GPG_KEY_ID
git commit -S -m "Secure commit"

# Protect main branch
# - Require PR reviews
# - Require status checks
# - Dismiss stale reviews
# - Require signed commits
```

### Scan for Secrets:

```bash
# Install git-secrets
brew install git-secrets

# Configure to scan for AWS keys, private keys, etc.
git secrets --install
git secrets --register-aws

# Scan repository
git secrets --scan

# Use in pipeline
stage('Secret Scan') {
    steps {
        sh 'git secrets --scan'
    }
}
```

---

## 8. AWS Security

### IAM Roles and Policies:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage"
            ],
            "Resource": [
                "arn:aws:eks:ap-south-1:ACCOUNT_ID:cluster/my-cluster",
                "arn:aws:ecr:ap-south-1:ACCOUNT_ID:repository/ekart"
            ]
        }
    ]
}
```

### EC2 Security:

```bash
# Restrict security group
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 22 \
  --cidr 203.0.113.0/32  # Your IP only

# Use Systems Manager instead of SSH
aws ssm start-session --target i-xxxxx

# Enable VPC Flow Logs
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-xxxxx \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs
```

---

## 9. Monitoring and Auditing

### Enable CloudTrail:

```bash
# Enable CloudTrail for all API calls
aws cloudtrail create-trail \
  --name ekart-trail \
  --s3-bucket-name ekart-audit-logs \
  --is-multi-region-trail

# Start logging
aws cloudtrail start-logging --trail-name ekart-trail
```

### CloudWatch Logs:

```bash
# Monitor Jenkins logs
aws logs create-log-group --log-group-name /jenkins/build-logs

# Monitor EKS logs
aws eks update-cluster-logging \
  --cluster-name my-cluster \
  --logging-config clusterLogging=[{enabled=true,types=[api,audit,authenticator,controllerManager,scheduler]}]
```

### Alerts:

```bash
# Create CloudWatch alarm for failed deployments
aws cloudwatch put-metric-alarm \
  --alarm-name deployment-failures \
  --alarm-description "Alert on failed EKS deployments" \
  --metric-name FailedDeployments \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold
```

---

## 10. Incident Response Plan

### Security Incident Procedure:

1. **Detect**: Monitor logs and alerts
2. **Respond**: Isolate affected systems
3. **Investigate**: Determine scope and impact
4. **Remediate**: Fix vulnerability and update code
5. **Document**: Create incident report
6. **Improve**: Update security practices

### Emergency Access:

```bash
# Break glass access (for emergencies)
# Use AWS Systems Manager for temporary access
# Document all access for audit

# Revoke compromised credentials immediately
aws iam delete-access-key --access-key-id AKIAIOSFODNN7EXAMPLE
```

---

## 11. Compliance Checklist

- [ ] All credentials stored in Jenkins/AWS Secrets Manager
- [ ] Network policies restricting traffic
- [ ] Container images scanned for vulnerabilities
- [ ] Kubernetes Pod Security Standards enforced
- [ ] RBAC configured with least privilege
- [ ] Audit logs enabled (CloudTrail, Container Insights)
- [ ] Data encrypted in transit (HTTPS/TLS)
- [ ] Database access restricted and logged
- [ ] Regular security patches applied
- [ ] Security scanning in CI/CD pipeline
- [ ] Incident response plan documented
- [ ] Regular backup and recovery tests

---

## 12. Security Tools and Resources

### Security Scanning:
- **Trivy**: Container vulnerability scanning
- **Snyk**: Dependency and container scanning
- **SonarQube**: Code quality and security
- **OWASP Dependency-Check**: Maven plugin
- **git-secrets**: Prevent committing secrets

### Infrastructure Security:
- **AWS Security Hub**: Centralized security monitoring
- **AWS Guard Duty**: Threat detection
- **Falco**: Runtime security monitoring
- **kube-bench**: Kubernetes security audits

### Resources:
- [OWASP Top 10](https://owasp.org/Top10/)
- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
- [Jenkins Security](https://www.jenkins.io/doc/book/security/)

---

## Summary

**Remember: Security is a continuous process, not a one-time task!**

1. Never hardcode credentials
2. Always use least privilege
3. Enable audit logging
4. Scan for vulnerabilities regularly
5. Keep systems updated
6. Test incident response procedures
7. Train team on security practices
