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
---
