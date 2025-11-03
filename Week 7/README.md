# Week 7 - CI/CD Pipeline Results

> **Note**: Project source code is located in Week 5 - 6

## 🚀 CI/CD Setup
- **GitHub Actions**: Automated build & push Docker images
- **ArgoCD**: GitOps deployment to Kubernetes
- **Application**: `my-demo-app`

## 📊 Pipeline Status

### ✅ GitHub Actions CI
```
✓ Build Spring Boot application
✓ Create Docker image
✓ Push to GitHub Container Registry
```
<img width="3359" height="1354" alt="image" src="https://github.com/user-attachments/assets/10e6e51b-82eb-492e-886d-b74aee4dbbce" />

### ✅ ArgoCD Deployment
```
Application Name: my-demo-app
Status: Healthy & Synced
Namespace: default
Image: ghcr.io/tamngo179/course-tracker:latest
```
<img width="2322" height="1759" alt="ảnh argo" src="https://github.com/user-attachments/assets/734322b9-c4f3-455b-829d-452a1a869bca" />


## 🌐 Access
- **ArgoCD Dashboard**: http://localhost:8080
- **Application**: Check pods with `kubectl get pods`

## 🔄 Workflow
1. Code push → GitHub Actions builds image
2. ArgoCD detects changes → Auto sync
3. Application deployed to Kubernetes

---
*CI/CD pipeline successfully automated!* 🎯
