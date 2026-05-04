# EKS Deployment and Management Guide

## Overview
Complete guide to deploy and manage applications on Amazon EKS (Elastic Kubernetes Service).

---

## Prerequisites

```bash
# Install AWS CLI
pip install awscli

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Install kubectl
curl -o kubectl https://amazon-eks-artifact-1234567890.s3.amazonaws.com/1.27/2023-08-16/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv kubectl /usr/local/bin/

# Install Helm (for installing ingress controller)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installations
aws --version
eksctl version
kubectl version --client
helm version
```

---

## Step 1: Create EKS Cluster

### Using eksctl (Recommended):

```bash
# Create cluster
eksctl create cluster \
  --name my-cluster \
  --region ap-south-1 \
  --nodegroup-name my-nodes \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 3 \
  --nodes-max 10 \
  --with-oidc \
  --enable-ssm \
  --managed \
  --version 1.27

# This will take 15-20 minutes

# Update kubeconfig
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name my-cluster

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

### Cluster Details:
- **Node Type**: t3.medium (2 vCPU, 1 GB RAM)
- **Initial Nodes**: 3
- **Max Nodes**: 10 (for auto-scaling)
- **Region**: ap-south-1 (Mumbai)
- **OIDC**: Enabled (for IAM roles)

---

## Step 2: Verify Cluster Setup

```bash
# Get cluster info
kubectl cluster-info

# List nodes
kubectl get nodes
kubectl describe nodes

# Check namespaces
kubectl get ns

# Check default services
kubectl get svc -A
```

---

## Step 3: Create Kubernetes Namespace (Optional)

```bash
# Create namespace
kubectl create namespace ekart

# Set as default
kubectl config set-context --current --namespace=ekart

# Verify
kubectl get ns
kubectl get pods -n ekart
```

---

## Step 4: Deploy Application

### Apply Kubernetes Manifests:

```bash
# Apply all manifests
kubectl apply -f kubernetes/

# Or apply individually
kubectl apply -f kubernetes/configmap-secret.yaml
kubectl apply -f kubernetes/rbac.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/hpa.yaml
kubectl apply -f kubernetes/network-policy.yaml
```

### What Gets Deployed:

1. **Namespace**: Isolated environment for application
2. **ConfigMap**: Configuration data
3. **Secret**: Sensitive data (credentials)
4. **ServiceAccount**: RBAC identity
5. **Deployment**: 3 replicas of application
6. **Service**: LoadBalancer for external access
7. **HPA**: Auto-scaling policy
8. **NetworkPolicy**: Security policies

---

## Step 5: Verify Deployment

```bash
# Check pods
kubectl get pods -l app=ekart
kubectl describe pod <POD_NAME>

# Check service
kubectl get svc ekart
kubectl describe svc ekart

# Check deployment
kubectl get deployment
kubectl describe deployment ekart

# Check logs
kubectl logs -l app=ekart
kubectl logs -l app=ekart --tail=100

# Follow logs (like tail -f)
kubectl logs -f -l app=ekart

# Get LoadBalancer endpoint
kubectl get svc ekart -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

---

## Step 6: Access Application

### Via LoadBalancer:

```bash
# Get LoadBalancer IP/Hostname
LOAD_BALANCER=$(kubectl get svc ekart -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application URL: http://$LOAD_BALANCER"

# Test application
curl http://$LOAD_BALANCER/api/health
curl http://$LOAD_BALANCER/api/info
```

### Via Port Forward (for testing):

```bash
# Forward local port to pod
kubectl port-forward pod/ekart-xxxxx 8080:8080

# In another terminal
curl http://localhost:8080/api/health
```

---

## Step 7: Update Application (Rolling Update)

### Update Deployment Image:

```bash
# Method 1: Update manifest and apply
sed -i 's|IMAGE_TAG|docker.io/username/ekart:2.0|g' kubernetes/deployment.yaml
kubectl apply -f kubernetes/deployment.yaml

# Method 2: Direct update
kubectl set image deployment/ekart \
  ekart=docker.io/username/ekart:2.0 \
  --record

# Check rollout status
kubectl rollout status deployment/ekart

# View rollout history
kubectl rollout history deployment/ekart

# Rollback if needed
kubectl rollout undo deployment/ekart
kubectl rollout undo deployment/ekart --to-revision=1
```

---

## Step 8: Scaling Application

### Manual Scaling:

```bash
# Scale to specific number of replicas
kubectl scale deployment ekart --replicas=5

# Verify
kubectl get pods -l app=ekart --no-headers | wc -l
```

### Auto-Scaling (HPA):

```bash
# Check HPA status
kubectl get hpa
kubectl describe hpa ekart-hpa

# View scaling events
kubectl get events --sort-by='.lastTimestamp'
```

---

## Step 9: Monitoring and Logging

### View Pod Resources:

```bash
# Check current resource usage
kubectl top nodes
kubectl top pods -l app=ekart

# View resource requests/limits
kubectl describe pod <POD_NAME> | grep -A 10 "Requests"
```

### View Logs:

```bash
# All pods logs
kubectl logs -l app=ekart --all-containers=true

# Previous logs (if container crashed)
kubectl logs -l app=ekart --previous

# Logs with timestamps
kubectl logs -l app=ekart --timestamps=true

# Log from specific container in pod
kubectl logs <POD_NAME> -c <CONTAINER_NAME>
```

### Streaming Logs:

```bash
# Stream logs from all pods
kubectl logs -f -l app=ekart --all-containers=true

# Stream from specific pod
kubectl logs -f <POD_NAME>
```

---

## Step 10: Install Monitoring Stack (Optional)

### Install Prometheus and Grafana:

```bash
# Add Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/prometheus \
  -n monitoring --create-namespace

# Install Grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana \
  -n monitoring \
  --set adminPassword=admin

# Access Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80
# Open http://localhost:3000 (admin/admin)
```

---

## Step 11: Install Ingress Controller (Optional)

For production deployments, use Ingress instead of LoadBalancer:

```bash
# Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer

# Get Ingress IP
kubectl get svc -n ingress-nginx

# Create Ingress resource
kubectl apply -f - << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ekart-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: ekart.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ekart
            port:
              number: 80
EOF
```

---

## Step 12: Backup and Disaster Recovery

### Backup Kubernetes Resources:

```bash
# Export all resources
kubectl get all -o yaml > backup-all.yaml

# Backup specific resource
kubectl get deployment ekart -o yaml > backup-deployment.yaml

# Backup Secrets and ConfigMaps
kubectl get secrets,configmaps -o yaml > backup-secrets.yaml

# Use Velero for production backups
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm install velero vmware-tanzu/velero \
  --namespace velero \
  --create-namespace \
  --set configuration.backupStorageLocation.bucket=ekart-backups
```

---

## Step 13: Cleanup and Removal

### Delete Application:

```bash
# Delete all resources in namespace
kubectl delete all --all -n default

# Delete specific resource
kubectl delete deployment ekart
kubectl delete service ekart

# Delete namespace
kubectl delete namespace ekart
```

### Delete EKS Cluster:

```bash
# Delete cluster
eksctl delete cluster --name my-cluster --region ap-south-1

# Or use AWS CLI
aws eks delete-cluster --name my-cluster --region ap-south-1
```

---

## Troubleshooting

### Pod Not Starting:

```bash
# Check pod events
kubectl describe pod <POD_NAME>

# Check logs
kubectl logs <POD_NAME> --previous
kubectl logs <POD_NAME>

# Check node resources
kubectl describe nodes

# Check resource quotas
kubectl describe resourcequota
```

### Service Not Accessible:

```bash
# Verify service exists
kubectl get svc ekart

# Check endpoints
kubectl get endpoints ekart

# Test connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  wget -O- http://ekart

# Check network policies
kubectl get networkpolicies
```

### Image Pull Issues:

```bash
# Check image availability
kubectl describe pod <POD_NAME> | grep "Image:"

# Verify credentials if using private image
kubectl create secret docker-registry regcred \
  --docker-server=docker.io \
  --docker-username=username \
  --docker-password=password

# Update deployment to use secret
kubectl set image-pull-secrets regcred deployment/ekart
```

---

## Best Practices

1. **Resource Limits**: Always set resource requests and limits
2. **Health Checks**: Implement liveness and readiness probes
3. **Security**: Use network policies and RBAC
4. **Monitoring**: Set up logging and monitoring
5. **Backup**: Regular backups of data and configuration
6. **Secrets**: Use Secrets for sensitive data, never hardcode
7. **Updates**: Use rolling updates for zero-downtime deployments
8. **Scaling**: Use HPA for automatic scaling based on metrics

---

## Useful Commands Reference

```bash
# Cluster Management
eksctl create cluster --name=my-cluster --region=ap-south-1
eksctl delete cluster --name=my-cluster
eksctl get clusters
eksctl scale nodegroup --cluster=my-cluster --nodes=5

# Deployment Management
kubectl apply -f <FILE>
kubectl delete -f <FILE>
kubectl rollout status deployment/ekart
kubectl rollout undo deployment/ekart

# Pod Management
kubectl get pods
kubectl describe pod <POD_NAME>
kubectl logs <POD_NAME>
kubectl exec -it <POD_NAME> -- /bin/sh

# Service Management
kubectl get svc
kubectl expose deployment ekart --type=LoadBalancer
kubectl port-forward svc/ekart 8080:80

# Scaling
kubectl scale deployment ekart --replicas=5
kubectl autoscale deployment ekart --min=3 --max=10

# Monitoring
kubectl top nodes
kubectl top pods
kubectl get events
```

---

## Next Steps

1. Configure DNS for application
2. Set up monitoring and alerting
3. Configure auto-backup
4. Plan disaster recovery procedure
5. Document runbooks for operations team
