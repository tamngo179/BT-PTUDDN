# Week 8 - Kubernetes Deployment, Prometheus Monitoring & AlertManager

## Tổng quan
Tuần 8 tập trung vào việc triển khai ứng dụng lên Kubernetes (K8s) với hệ thống monitoring hoàn chỉnh sử dụng Prometheus, Grafana và AlertManager. Bao gồm cấu hình cảnh báo tự động qua email, Slack, webhook khi CPU > 80%, cùng với load testing sử dụng JMeter để kiểm tra hiệu năng và trigger alerts.

## Cấu trúc thư mục

```
Week 8/
├── k8s/                    # Kubernetes manifests
│   ├── namespace.yaml      # Tạo namespace cho ứng dụng
│   ├── deployment.yaml     # Deployment configuration
│   ├── service.yaml        # Service exposure
│   ├── ingress.yaml        # Ingress controller
│   └── configmap.yaml      # Configuration maps
├── monitoring/             # Prometheus, Grafana & AlertManager setup
│   ├── prometheus/
│   │   ├── prometheus-config.yaml    # Prometheus configuration với AlertManager
│   │   ├── prometheus-deployment.yaml
│   │   └── prometheus-service.yaml
│   ├── grafana/
│   │   ├── grafana-deployment.yaml
│   │   ├── grafana-service.yaml
│   │   └── dashboards/
│   ├── alertmanager/       # 🚨 AlertManager configuration
│   │   ├── alertmanager-config.yaml   # Email, Slack, Webhook config
│   │   ├── prometheus-rules.yaml      # CPU > 80% alerting rules
│   │   └── alertmanager-deployment.yaml # K8s deployment
│   ├── jmeter/            # 📊 Load testing với JMeter
│   │   ├── cpu-load-test.jmx          # JMeter test plan
│   │   ├── run-load-test.ps1          # PowerShell script
│   │   └── README.md                  # Hướng dẫn load test
│   └── servicemonitor.yaml # Service monitoring configuration
├── scripts/                # Deployment scripts
│   ├── deploy.sh          # Deployment script (Linux/macOS)
│   ├── deploy.ps1         # Deployment script (Windows PowerShell)
│   ├── setup-monitoring.sh
│   ├── setup-alerting.ps1  # 🚨 Setup AlertManager
│   └── cleanup.sh
├── results/               # Kết quả deployment
│   ├── screenshots/       # Screenshots của Grafana dashboards & alerts
│   ├── logs/             # Application và system logs
│   ├── metrics/          # Exported metrics
│   └── jmeter-reports/   # 📊 JMeter load test results
└── README.md             # File này
```

## Quy trình Deployment

### 1. Chuẩn bị môi trường K8s
```powershell
# Kiểm tra Kubernetes cluster
kubectl cluster-info
kubectl get nodes

# Tạo namespace
kubectl create namespace bookstore-app
```

### 2. Deploy ứng dụng
```powershell
# Deploy tất cả manifest files
cd "Week 8/k8s"
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Kiểm tra deployment
kubectl get pods -n bookstore-app
kubectl get services -n bookstore-app
```

### 3. Cài đặt Prometheus Monitoring

```powershell
cd "Week 8/monitoring"
kubectl apply -f prometheus/
kubectl apply -f grafana/
kubectl apply -f servicemonitor.yaml
```

### 4. 🚨 Cài đặt AlertManager & Alerting Rules

```powershell
# Deploy AlertManager và alerting rules
kubectl apply -f alertmanager/alertmanager-config.yaml
kubectl apply -f alertmanager/prometheus-rules.yaml
kubectl apply -f alertmanager/alertmanager-deployment.yaml

# Cập nhật Prometheus config để kết nối AlertManager
kubectl delete configmap prometheus-config -n monitoring
kubectl apply -f prometheus-config.yaml
kubectl rollout restart deployment prometheus -n monitoring
```

### 5. 📊 Chạy Load Test với JMeter

```powershell
# Cài đặt JMeter (nếu chưa có)
# Download từ: https://jmeter.apache.org/download_jmeter.cgi

# Chạy load test để trigger CPU alerts
cd monitoring/jmeter
.\run-load-test.ps1

# Hoặc chạy thủ công
jmeter -t cpu-load-test.jmx
```

### 6. Truy cập ứng dụng và monitoring

#### Prometheus
```powershell
# Port-forward để truy cập Prometheus
kubectl port-forward svc/prometheus-server 9090:80 -n monitoring
# Truy cập: http://localhost:9090
```

#### Grafana
```powershell
# Port-forward để truy cập Grafana
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
# Truy cập: http://localhost:3000
# Username: admin, Password: admin123
```

#### AlertManager 🚨
```powershell
# Truy cập AlertManager UI
# URL: http://localhost:30093
# Xem alerts hiện tại và configuration
```
