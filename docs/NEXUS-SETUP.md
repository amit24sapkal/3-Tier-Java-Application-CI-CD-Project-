# Nexus Setup and Configuration Guide

## Overview
Complete guide to set up and configure Nexus 3 for artifact repository management.

---

## Step 1: Verify Nexus Installation

```bash
# Check if container is running
sudo docker ps | grep nexus

# View container logs
sudo docker logs nexus

# Get initial admin password
NEXUS_PASSWORD=$(sudo docker exec nexus cat /nexus-data/admin.password)
echo "Nexus Admin Password: $NEXUS_PASSWORD"
```

---

## Step 2: Access Nexus Dashboard

1. Open browser: `http://<NEXUS-IP>:8081`
2. Click **Sign In** (top-right)
3. Username: `admin`
4. Password: (from command above)
5. Click **Sign in**

---

## Step 3: Change Admin Password

1. Click **Sign in** → **Settings** (gear icon)
2. Go to **Users**
3. Click **admin** user
4. Click **Set Password**
5. Enter new password
6. Click **Save**
7. **Save the new password securely**

---

## Step 4: Configure Repositories

### View Existing Repositories:

1. Click **Settings** (gear icon)
2. Go to **Repositories**
3. Default repositories:
   - `maven-snapshots` - Snapshot artifacts
   - `maven-releases` - Release artifacts
   - `maven-public` - Public proxy

### Create Custom Repository (Optional):

1. Click **Create repository**
2. Select **maven2 (hosted)**
3. Configure:
   - **Name**: `project-artifacts`
   - **Version policy**: `Release`
   - **Deployment policy**: `Allow redeploy`
4. Click **Create repository**

---

## Step 5: Create Blob Store (Optional)

For better storage management:

1. Click **Settings** (gear icon)
2. Go to **Blob Stores**
3. Click **Create Blob Store**
4. Type: **File**
5. Name: `project-blob`
6. Click **Create Blob Store**
7. Assign to repositories in repository configuration

---

## Step 6: Create Roles and Users

### Create Role for CI/CD:

1. Click **Settings** (gear icon)
2. Go to **Roles**
3. Click **Create role**
4. **Role ID**: `cicd-role`
5. **Role Name**: `CI/CD Pipeline Role`
6. Permissions:
   - [ ] `nx-all`
   - Or be more specific:
     - [ ] `nx-repository-view-*-*-read`
     - [ ] `nx-repository-view-*-*-browse`
     - [ ] `nx-repository-view-*-*-edit`
     - [ ] `nx-repository-admin-*-*-manage`
7. Click **Create role**

### Create User for Jenkins:

1. Click **Settings** (gear icon)
2. Go to **Users**
3. Click **Create user**
4. Configure:
   - **User ID**: `jenkins`
   - **First name**: `Jenkins`
   - **Last name**: `CI/CD`
   - **Email**: `jenkins@company.com`
   - **Password**: (strong password)
   - **Status**: `Active`
   - **Roles**: Select `cicd-role`
5. Click **Create user**
6. **Save credentials for Jenkins**

---

## Step 7: Configure Maven Settings

### On Jenkins Server:

Create/modify `~/.m2/settings.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
          http://maven.apache.org/xsd/settings-1.0.0.xsd">
    
    <servers>
        <server>
            <id>maven-releases</id>
            <username>jenkins</username>
            <password>JENKINS_PASSWORD_HERE</password>
        </server>
        <server>
            <id>maven-snapshots</id>
            <username>jenkins</username>
            <password>JENKINS_PASSWORD_HERE</password>
        </server>
        <server>
            <id>nexus</id>
            <username>jenkins</username>
            <password>JENKINS_PASSWORD_HERE</password>
        </server>
    </servers>
    
    <mirrors>
        <mirror>
            <id>nexus</id>
            <mirrorOf>*</mirrorOf>
            <url>http://NEXUS_IP:8081/repository/maven-public/</url>
        </mirror>
    </mirrors>
    
    <profiles>
        <profile>
            <id>nexus</id>
            <repositories>
                <repository>
                    <id>central</id>
                    <url>http://NEXUS_IP:8081/repository/maven-public/</url>
                    <releases><enabled>true</enabled></releases>
                    <snapshots><enabled>true</enabled></snapshots>
                </repository>
            </repositories>
            <pluginRepositories>
                <pluginRepository>
                    <id>central</id>
                    <url>http://NEXUS_IP:8081/repository/maven-public/</url>
                    <releases><enabled>true</enabled></releases>
                    <snapshots><enabled>true</enabled></snapshots>
                </pluginRepository>
            </pluginRepositories>
        </profile>
    </profiles>
    
    <activeProfiles>
        <activeProfile>nexus</activeProfile>
    </activeProfiles>
    
</settings>
```

---

## Step 8: Configure Proxies (Optional)

For downloading dependencies from public repositories:

1. Click **Settings** (gear icon)
2. Go to **Repositories**
3. Create **maven2 (proxy)**:
   - **Name**: `maven-central-proxy`
   - **Remote storage**: `https://repo1.maven.org/maven2/`
   - **Location**: Select default blob store
4. Click **Create repository**

---

## Step 9: Configure Docker Registry (Optional)

If using Docker images with Nexus:

1. Create repositories:
   - Type: **docker (hosted)**
   - Name: `docker-releases`
   - Port: `8082`

2. Create proxy:
   - Type: **docker (proxy)**
   - Name: `docker-proxy`
   - Remote URL: `https://registry-1.docker.io`
   - Port: `8083`

3. Create group:
   - Type: **docker (group)**
   - Name: `docker-group`
   - Members: `docker-releases`, `docker-proxy`
   - Port: `8084`

---

## Step 10: Cleanup Policies

Set up automatic cleanup of old artifacts:

1. Click **Settings** (gear icon)
2. Go to **Cleanup Policies**
3. Click **Create cleanup policy**
4. Configure:
   - **Name**: `cleanup-old-snapshots`
   - **Criteria**:
     - Last downloaded: 30 days
     - Release type: Snapshot
5. Click **Create cleanup policy**

---

## Step 11: Backup and Restore

### Backup:

```bash
# Backup Nexus data directory
sudo docker exec nexus tar czf - /nexus-data | \
    gzip > nexus-backup-$(date +%Y%m%d).tar.gz

# Backup database
sudo docker volume ls
sudo docker exec nexus tar czf - /nexus-data/db | \
    gzip > nexus-db-backup-$(date +%Y%m%d).tar.gz
```

### Restore:

```bash
# Restore data
sudo docker stop nexus
sudo docker rm nexus
gunzip < nexus-backup.tar.gz | tar x -C /
sudo docker run -d -p 8081:8081 \
    --name nexus \
    -v /nexus-data:/nexus-data \
    sonatype/nexus3:latest
```

---

## Step 12: Configure in pom.xml

Add to your application's `pom.xml`:

```xml
<distributionManagement>
    <repository>
        <id>maven-releases</id>
        <name>Nexus Release Repository</name>
        <url>http://NEXUS_IP:8081/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
        <id>maven-snapshots</id>
        <name>Nexus Snapshot Repository</name>
        <url>http://NEXUS_IP:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
</distributionManagement>

<repositories>
    <repository>
        <id>nexus</id>
        <name>Nexus Repository</name>
        <url>http://NEXUS_IP:8081/repository/maven-public/</url>
        <releases>
            <enabled>true</enabled>
        </releases>
        <snapshots>
            <enabled>true</enabled>
        </snapshots>
    </repository>
</repositories>
```

---

## Step 13: Jenkins Integration

### Jenkins Pipeline:

```groovy
stage('Upload to Nexus') {
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

### Using Nexus Artifact Uploader Plugin:

```groovy
stage('Upload Artifact') {
    steps {
        nexusArtifactUploader(
            nexusVersion: 'nexus3',
            protocol: 'http',
            nexusUrl: 'NEXUS_IP:8081',
            groupId: 'com.ekart',
            version: '${BUILD_ID}',
            repository: 'maven-releases',
            credentialsId: 'nexus-credentials',
            artifacts: [
                [artifactId: 'ekart-app',
                 classifier: '',
                 file: 'target/ekart-app-1.0.0.jar',
                 type: 'jar']
            ]
        )
    }
}
```

---

## Troubleshooting

### Nexus Won't Start
```bash
sudo docker logs nexus
sudo docker restart nexus
```

### Permission Denied on Upload
- Verify user has correct role
- Check `maven-releases` repository write permissions
- Verify credentials in `settings.xml`

### Connection Refused
- Verify Nexus is running: `curl http://NEXUS_IP:8081`
- Check network connectivity
- Verify firewall rules

### Disk Space Issues
```bash
# Check disk usage
sudo docker exec nexus du -sh /nexus-data

# Run cleanup
# Go to Tasks in admin panel and execute cleanup policy
```

---

## Performance Tuning

### Increase Memory:
```bash
sudo docker stop nexus
sudo docker run -d -p 8081:8081 \
    -e INSTALL4J_ADD_VM_PARAMS="-Xms1024m -Xmx2048m" \
    --name nexus \
    sonatype/nexus3:latest
```

### Database Optimization:
- Use PostgreSQL instead of H2 for production
- Configure in `nexus.properties`

---

## Security Best Practices

1. **Change Default Password**: Always change admin password
2. **Disable Anonymous Access**: Remove anonymous user
3. **Use HTTPS**: Configure SSL/TLS certificate
4. **Create Restricted Users**: Use role-based access control
5. **Enable Audit Log**: Monitor all operations
6. **Regular Backups**: Schedule automated backups
7. **Restrict Network Access**: Use firewall rules

---

## Next Steps

1. Configure Jenkins to use Nexus (see JENKINS-SETUP.md)
2. Set up artifact retention policies
3. Configure backup automation
4. Monitor storage usage
5. Create project-specific repositories and users
