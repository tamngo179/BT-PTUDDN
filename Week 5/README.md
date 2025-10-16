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

<img width="1755" height="1226" alt="image" src="https://github.com/user-attachments/assets/0e966933-24ba-4b27-870d-a1e0f567855a" />


# Xem logs container
docker logs course-tracker
```
---
