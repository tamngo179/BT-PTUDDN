# Week 5 CI/CD Setup Guide

## Tổng quan

Workflow CI/CD này tự động:
1. **Build Docker image** khi có commit/push vào thư mục `week 5/`
2. **Push image** lên GitHub Container Registry và Docker Hub
3. **Update Kubernetes manifests** với image tag mới
4. **Chạy security scan** với Trivy
5. **Thông báo kết quả** deployment

## Cấu hình Secrets

Để workflow hoạt động, cần cấu hình các secrets sau trong GitHub repository:

### Required Secrets

1. **DOCKERHUB_USERNAME** - Docker Hub username
2. **DOCKERHUB_TOKEN** - Docker Hub access token

### Cách tạo Docker Hub Access Token

1. Đăng nhập [Docker Hub](https://hub.docker.com/)
2. Vào **Account Settings** → **Security**
3. Click **New Access Token**
4. Chọn **Read, Write, Delete** permissions
5. Copy token và thêm vào GitHub Secrets

### Cách thêm Secrets vào GitHub

1. Vào repository trên GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Thêm từng secret:
   - Name: `DOCKERHUB_USERNAME`, Value: `your-dockerhub-username`
   - Name: `DOCKERHUB_TOKEN`, Value: `your-dockerhub-token`

## Workflow Triggers

Workflow chạy khi:
- **Push** vào branch `main` hoặc `develop` với changes trong `week 5/`
- **Pull Request** vào `main` với changes trong `week 5/`

## Jobs Overview

### 1. build-and-push
- Build Docker image từ `week 5/simple-app/Dockerfile`
- Push lên:
  - GitHub Container Registry: `ghcr.io/[owner]/simple-app`
  - Docker Hub: `[username]/simple-app`
- Tags được tạo:
  - `latest` (chỉ trên main branch)
  - `sha-[commit-hash]`
  - `main` hoặc `develop` (theo branch)

### 2. update-k8s-manifests
- Chỉ chạy khi push vào `main` branch
- Tự động tạo/update Kubernetes manifests trong `week 5/k8s/`
- Include:
  - **Deployment** với 3 replicas
  - **Service** type ClusterIP
  - **Ingress** với host `simple-app.local`
  - **Kustomization** file
- Update image tag trong manifests
- Commit changes trở lại repo

### 3. security-scan
- Scan Docker image với Trivy
- Upload kết quả lên GitHub Security tab
- Check for vulnerabilities

### 4. notify
- Thông báo status của toàn bộ pipeline
- Show image URLs và deployment info

## Kubernetes Manifests

Workflow tự động tạo các manifest files:

```
week 5/k8s/
├── deployment.yaml    # Deployment + Service + Ingress
└── kustomization.yaml # Kustomize configuration
```

### Deployment Features
- **3 replicas** for high availability
- **Resource limits**: 512Mi memory, 500m CPU
- **Health checks**: Readiness + Liveness probes tại `/health`
- **Environment**: `SPRING_PROFILES_ACTIVE=production`

### Service & Ingress
- **Internal Service** trên port 80 → 8080
- **Ingress** với host `simple-app.local`
- **TLS** support với cert-manager

## Local Testing

### Test Docker Build
```bash
cd "week 5/simple-app"
docker build -t simple-app:test .
docker run -p 8080:8080 simple-app:test
```

### Test Kubernetes Manifests
```bash
# Sau khi workflow chạy
kubectl apply -k "week 5/k8s/"

# Hoặc dry-run
kubectl apply --dry-run=client -k "week 5/k8s/"
```

### Test Endpoints
```bash
# Health check
curl http://localhost:8080/health

# Main endpoint  
curl http://localhost:8080/
```

## Troubleshooting

### Build Errors
1. Kiểm tra Dockerfile syntax
2. Verify source code compiles locally
3. Check Maven dependencies

### Push Errors
1. Verify Docker Hub credentials
2. Check repository permissions
3. Ensure GITHUB_TOKEN có write packages permission

### K8s Manifest Errors
1. Validate YAML syntax
2. Check Kubernetes API versions
3. Verify resource names và labels

### Security Scan Failures
- Review Trivy scan results trong GitHub Security tab
- Update base images nếu có vulnerabilities
- Check for outdated dependencies

## Image Locations

Sau khi workflow chạy thành công:

**GitHub Container Registry:**
```
ghcr.io/tamngo179/simple-app:latest
ghcr.io/tamngo179/simple-app:sha-[commit-hash]
```

**Docker Hub:**
```
[username]/simple-app:latest  
[username]/simple-app:sha-[commit-hash]
```

## Next Steps

1. **Setup monitoring** với Prometheus/Grafana
2. **Add integration tests** trong pipeline
3. **Setup staging environment** 
4. **Configure auto-deployment** với ArgoCD
5. **Add notification** với Slack/Teams