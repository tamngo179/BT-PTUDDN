# Spring Boot Course Tracker - Docker Container

## 📦 Build & Deploy

### Bước 1: Build Docker Image

```bash
# Build image với tag course-tracker:latest
docker build -t course-tracker:latest .
```
<img width="1728" height="1109" alt="image" src="https://github.com/user-attachments/assets/452a0fa4-33d2-4420-83c6-9a0b2f3c3677" />

---

### Bước 2: Chạy Container

```bash
# Chạy container với port mapping
docker run -d -p 8080:8080 --name course-tracker course-tracker:latest

# Kiểm tra container đang chạy
docker ps
```
<img width="1758" height="940" alt="image" src="https://github.com/user-attachments/assets/d781652f-3f95-4230-93e9-92c697fdba6e" />
```
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

# Check resource usage (requires metrics server)
kubectl top pods -l app=course-tracker
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

### 🔧 Troubleshooting

**Error: "Metrics API not available"**

This error occurs when running `kubectl top` commands. Docker Desktop doesn't include metrics server by default.

**Solution 1: Install Metrics Server**
```bash
# Install metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Patch for Docker Desktop (bypass TLS verification)
kubectl patch deployment metrics-server -n kube-system --patch '
spec:
  template:
    spec:
      containers:
      - name: metrics-server
        args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls'

# Wait for metrics server to be ready
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=60s

# Test metrics
kubectl top nodes
kubectl top pods -l app=course-tracker
```

**Solution 2: Alternative Monitoring**
```bash
# Use describe instead of top
kubectl describe pods -l app=course-tracker

# Check resource requests/limits
kubectl get pods -l app=course-tracker -o yaml | grep -A 10 resources

# Monitor without metrics server
kubectl get pods -l app=course-tracker --watch
```

---
