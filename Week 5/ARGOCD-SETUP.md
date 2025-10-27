# Week 5 ArgoCD Deployment Guide

## 📋 Tổng quan

Workflow này sử dụng ArgoCD để thực hiện Continuous Deployment (CD) cho ứng dụng Week 5, bao gồm:

- **Tự động deploy** sau khi CI pipeline thành công
- **Multi-environment** deployment (staging → production)
- **GitOps workflow** với ArgoCD
- **Rollback capability** khi deployment thất bại
- **Notification system** cho deployment events

## 🏗️ Kiến trúc Deployment

```
CI Pipeline (ci.yml) → CD Pipeline (cd.yml) → ArgoCD → Kubernetes
     ↓                      ↓                   ↓           ↓
Build Image         Check CI Status      Sync Apps    Deploy Pods
Push to Registry    Update ArgoCD Apps   Monitor       Health Checks
Update Manifests    Validate Deploy      Notify        Service Ready
```

## 🚀 Setup Prerequisites

### 1. ArgoCD Installation

```bash
# Install ArgoCD in cluster
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Expose ArgoCD Server
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 2. GitHub Secrets Configuration

Cần cấu hình các secrets sau trong GitHub repository:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `ARGOCD_SERVER` | ArgoCD server URL | `argocd.example.com` |
| `ARGOCD_TOKEN` | ArgoCD authentication token | `eyJhbGciOiJ...` |
| `GITHUB_TOKEN` | GitHub PAT (có sẵn) | Auto-generated |

### 3. Tạo ArgoCD Authentication Token

```bash
# Login to ArgoCD CLI
argocd login <ARGOCD_SERVER>

# Create service account
argocd account create github-actions --in-cluster

# Generate token
argocd account generate-token --account github-actions
```

## 📂 File Structure

```
week 5/
├── argocd/
│   ├── applications.yaml    # ArgoCD Applications
│   ├── project.yaml        # ArgoCD Project
│   └── notifications.yaml  # Notification config
├── k8s/
│   ├── deployment.yaml     # K8s manifests
│   └── kustomization.yaml  # Kustomize config
└── CI-CD-SETUP.md         # This file
```

## 🔄 Workflow Operations

### 1. Automatic Deployment Flow

1. **CI Pipeline** hoàn thành thành công
2. **CD Pipeline** được trigger tự động
3. **Staging deployment**:
   - Update ArgoCD application
   - Sync with new image tag
   - Validate deployment health
4. **Production deployment** (chỉ trên main branch):
   - Manual approval required
   - Update production app
   - Health validation

### 2. Manual Deployment

```bash
# Trigger manual deployment
gh workflow run cd.yml \
  --field environment=staging \
  --field image_tag=sha-abc123 \
  --field force_sync=true
```

### 3. Rollback Process

Khi deployment thất bại, workflow tự động:
1. Detect failure
2. Get previous successful revision
3. Rollback ArgoCD application
4. Validate rollback success

## 🎯 Environment Configuration

### Staging Environment

- **Namespace**: `staging`
- **Replicas**: 2
- **Resources**: 256Mi memory, 250m CPU
- **Sync Policy**: Automated (prune + self-heal)
- **Profile**: `staging`

### Production Environment

- **Namespace**: `production`
- **Replicas**: 5
- **Resources**: 1Gi memory, 1000m CPU
- **Sync Policy**: Manual (requires approval)
- **Profile**: `production`

## 📊 Monitoring & Notifications

### ArgoCD Dashboard

```bash
# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open: https://localhost:8080
```

### Application Status

```bash
# Check application status
argocd app get simple-app-staging
argocd app get simple-app-production

# View deployment history
argocd app history simple-app-staging
```

### Notification Channels

Configured notifications for:
- ✅ **Successful deployments**
- ⚠️ **Health degradation**
- ❌ **Sync failures**

Channels:
- **Slack**: `#simple-app-channel`
- **Email**: `dev-team@company.com`

## 🛠️ Management Commands

### ArgoCD CLI Commands

```bash
# Sync application manually
argocd app sync simple-app-staging --prune

# Force sync (ignore differences)
argocd app sync simple-app-staging --force

# Rollback to previous version
argocd app rollback simple-app-staging

# View application details
argocd app get simple-app-staging -o yaml

# Check application logs
argocd app logs simple-app-staging
```

### Kubernetes Commands

```bash
# Check deployment status
kubectl get deployments -n staging
kubectl get pods -n staging -l app=simple-app

# View application logs
kubectl logs -n staging -l app=simple-app --tail=100

# Port forward to test app
kubectl port-forward -n staging svc/simple-app-service 8080:80
```

## 🔧 Troubleshooting

### Common Issues

1. **ArgoCD Authentication Failed**
   ```bash
   # Check token validity
   argocd account list
   
   # Regenerate token
   argocd account generate-token --account github-actions
   ```

2. **Sync Out of Sync**
   ```bash
   # Check differences
   argocd app diff simple-app-staging
   
   # Manual sync with prune
   argocd app sync simple-app-staging --prune --force
   ```

3. **Application Unhealthy**
   ```bash
   # Check application status
   kubectl describe deployment simple-app -n staging
   kubectl get events -n staging --sort-by='.lastTimestamp'
   ```

4. **Image Pull Errors**
   ```bash
   # Check image exists
   docker pull ghcr.io/tamngo179/simple-app:sha-abc123
   
   # Check image pull secrets
   kubectl get secrets -n staging
   ```

### Debug Commands

```bash
# ArgoCD application debug
argocd app get simple-app-staging --show-operation
argocd app logs simple-app-staging --kind Deployment

# Kubernetes debug
kubectl describe pod <pod-name> -n staging
kubectl logs <pod-name> -n staging -c simple-app
```

## 🔐 Security Best Practices

1. **RBAC Configuration**
   - Developer: staging access only
   - Operator: full access
   - Viewer: read-only

2. **Secret Management**
   - Use Kubernetes secrets for sensitive data
   - Rotate ArgoCD tokens regularly
   - Separate service accounts per environment

3. **Network Policies**
   - Isolate staging and production namespaces
   - Control ingress/egress traffic
   - Monitor network access

## 📈 Performance Monitoring

### Metrics Collection

```bash
# Application metrics
curl http://simple-app-staging.local/actuator/metrics

# ArgoCD metrics
kubectl port-forward -n argocd svc/argocd-metrics 8082:8082
curl http://localhost:8082/metrics
```

### Health Checks

- **Readiness Probe**: `/health` endpoint
- **Liveness Probe**: `/health` endpoint  
- **Startup Probe**: Initial application boot

## 🔄 Upgrade Procedures

### ArgoCD Upgrade

```bash
# Backup current installation
kubectl get applications -n argocd -o yaml > argocd-backup.yaml

# Upgrade ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Application Upgrade

1. CI pipeline builds new image
2. CD pipeline updates ArgoCD apps
3. ArgoCD syncs with cluster
4. Rolling update performed
5. Health checks validate deployment

## 📚 References

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kustomize.io/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Kubernetes Documentation](https://kubernetes.io/docs/)