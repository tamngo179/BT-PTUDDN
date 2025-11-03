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
  - `alertmanager/` — AlertManager setup (config, rules, deployment)
  - `scripts/` — Deployment scripts (deploy.sh, deploy.ps1, setup-monitoring.sh)
  - `results/` — Kết quả deployment (screenshots, logs, metrics)
  - `README.md` — Hướng dẫn chi tiết K8s deployment và Prometheus monitoring
