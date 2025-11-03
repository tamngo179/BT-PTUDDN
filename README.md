# BT-PTUDDN

Tài liệu ngắn mô tả cấu trúc thư mục của repository này.

## Mô tả chung
Repository chứa các bài tập / demo cho các tuần (Week 4, Week 5-6, Week 7, Week 8). Mỗi thư mục tuần thường chứa một ứng dụng Spring Boot demo hoặc tài nguyên liên quan (Dockerfile, k8s manifests, monitoring setup, v.v.).

## Cấu trúc thư mục

- `Week 4/`
  - `demo/`
    - `pom.xml` — cấu hình Maven cho bài demo tuần 4
    - `src/main/java/com/example/` — mã nguồn Java (controller, security, v.v.)
    - `src/main/resources/templates/` — các template HTML (`index.html`, `home.html`)
    - `src/main/resources/application.properties` — cấu hình ứng dụng
  - `target/` — (thư mục build, sinh ra khi mvn package)

- `Week 5 - 6/`
  - `Dockerfile`, `mvnw`, `mvnw.cmd`, `pom.xml` — tập tin phục vụ build và đóng gói
  - `demo/` — ứng dụng Spring Boot mẫu (đã tổ chức thành package `com.example.demo`)
    - `controller/`, `model/`, `repository/`, `service/` — các lớp theo mô hình MVC
    - `resources/templates/` — giao diện (HTML)
  - `k8s/` — manifest Kubernetes (deployment, service, ingress, configmap)
  - `start.sh` — script khởi động (Linux/macOS)

- `Week 7/`
  - `ci/` — kết quả và cấu hình CI/CD (ví dụ: workflow, logs, artifacts, badges)
  - `README.md` — ghi chú tóm tắt kết quả CI/CD, hướng dẫn truy cập artifacts hoặc xem pipeline

- `Week 8/`
  - `k8s/` — Kubernetes deployment manifests (namespace, deployment, service, ingress)
  - `monitoring/` — Prometheus và Grafana setup (config, dashboards, servicemonitor)
  - `scripts/` — Deployment scripts (deploy.sh, deploy.ps1, setup-monitoring.sh)
  - `results/` — Kết quả deployment (screenshots, logs, metrics)
  - `README.md` — Hướng dẫn chi tiết K8s deployment và Prometheus monitoring

- `BookStore/` — Ứng dụng BookStore hoàn chỉnh
  - Các microservices: `account-service`, `catalog-service`, `order-service`, etc.
  - `k8s/`, `argoCD/` — Kubernetes và ArgoCD manifests
  - `bookstore-frontend-react-app/` — Frontend React
  - `docker-compose.yml`, `Dockerfile` — Container configuration


## Tệp quan trọng khác
- `.gitignore` — (có thể bị xóa/khôi phục trong repo của bạn)
- `README.md` (tại thư mục gốc) — tệp này (tóm tắt cấu trúc)


## Gợi ý chạy nhanh (Windows PowerShell)
Yêu cầu: Java (11+), Maven (hoặc sử dụng `mvnw` nếu có), Docker, Kubernetes.

### Chạy ứng dụng Spring Boot (Week 5-6)
```powershell
# chuyển vào thư mục có ứng dụng Spring Boot
cd "Week 5 - 6"
# trên Windows dùng mvnw.cmd
.\.\mvnw.cmd spring-boot:run
# hoặc nếu đã cài maven
mvn spring-boot:run
```

### Deploy lên Kubernetes (Week 8)
```powershell
# Deploy ứng dụng lên K8s với monitoring
cd "Week 8"
kubectl apply -f k8s/
# Setup Prometheus monitoring
.\scripts\setup-monitoring.ps1
```

### Chạy BookStore App hoàn chỉnh
```powershell
cd BookStore
# Sử dụng Docker Compose
docker-compose up -d
# Hoặc deploy lên K8s
kubectl apply -f k8s/
```

## Gợi ý cho Git (tuỳ chọn)
Sau khi kiểm tra thay đổi, bạn có thể commit và push:

```powershell
cd "d:\demo\BT-PTUDDN"
git add .
git commit -m "Add Week 8: Kubernetes deployment and Prometheus monitoring"
git push origin main
```


---
Tệp này được tạo tự động để giúp bạn nhanh chóng nắm được cấu trúc repo. Nếu muốn, tôi có thể mở rộng phần hướng dẫn chạy hoặc thêm sơ đồ chi tiết cho từng ứng dụng.