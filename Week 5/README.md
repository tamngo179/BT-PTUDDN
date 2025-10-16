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
---
