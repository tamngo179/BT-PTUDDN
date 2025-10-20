# Spring Boot Course Tracker - Docker Container

## 📦 Build & Deploy

### Bước 1: Build Docker Image

```bash
# Build image với tag course-tracker:latest
docker build -t course-tracker:latest .
```

![Build Docker Image](images/docker-build-success.png)
---

### Bước 2: Chạy Container

```bash
# Chạy container với port mapping
docker run -d -p 8080:8080 --name course-tracker course-tracker:latest

# Kiểm tra container đang chạy
docker ps

# Xem logs container
docker logs course-tracker
```

![Docker Container Running](images/docker-container-running.png)

---

## ☸️ Deploy to Kubernetes (Docker Desktop)

### Prerequisites
1. **Enable Kubernetes in Docker Desktop:**
   - Open Docker Desktop → Settings → Kubernetes
   - Check "Enable Kubernetes" → Apply & Restart

2. **Verify setup:**
```bash
kubectl cluster-info
kubectl get nodes
```

### Deploy Steps

**1. Apply Kubernetes manifests:**
```bash
kubectl apply -f k8s/
```

**2. Check deployment:**
```bash
# Check pods status
kubectl get pods -l app=course-tracker

# Check service
kubectl get service course-tracker-service
```

**3. Access application:**
```bash
# Get service URL (Docker Desktop provides localhost access)
kubectl get service course-tracker-service

# Access via browser: http://localhost:<EXTERNAL-PORT>
```

**4. Monitor:**
```bash
# View logs
kubectl logs -l app=course-tracker -f

# Scale replicas
kubectl scale deployment course-tracker-deployment --replicas=3
```

**5. Cleanup:**
```bash
kubectl delete -f k8s/
```

### K8s Resources Created
- **Deployment**: 2 replicas with health checks
- **Service**: LoadBalancer type for external access  
- **ConfigMap**: Application configuration
- **Ingress**: Optional domain-based routing

---
