
# Bài tập tuần 4

Ứng dụng Spring Boot dùng OIDC (không SAML) và yêu cầu `offline_access` để nhận Refresh Token.

Biến môi trường chính:
- `AUTH0_ISSUER_URI` — OIDC issuer URL
- `AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET`

Endpoint quan trọng:
- `GET /me` — thông tin user
- `GET /tokens` — xem id/access/refresh token
- `POST /refresh` — làm mới token
- `GET /logout` — redirect logout (Auth0)

Chạy (PowerShell):
```powershell
mvn -DskipTests package
mvn spring-boot:run
```
---
