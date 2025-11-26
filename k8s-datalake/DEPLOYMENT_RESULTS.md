# Data Lake với MinIO và DuckDB trên Kubernetes

## ✅ Kết quả triển khai thành công

### 1. MinIO Cluster đã triển khai
- **3 replicas** MinIO pods đang chạy trên namespace `datalake`
- **Persistent Storage** với 1Gi cho mỗi replica
- **S3-compatible API** tại `http://localhost:19000`
- **MinIO Console** tại `http://localhost:19001`

### 2. Dữ liệu CSV đã được lưu trữ
- Bucket `csv-data` đã được tạo
- File `sample_data.csv` (100 records) đã upload thành công
- Dữ liệu bao gồm: id, name, age, city, salary

### 3. Truy vấn dữ liệu hoạt động
- ✅ Upload CSV: `python upload_csv_data.py`
- ✅ Query với Pandas: `python query_csv_pandas.py`
- ⚠️ DuckDB: có vấn đề trên Windows, sử dụng Pandas thay thế

### 4. Các tính năng đã test
- [x] Tạo và quản lý bucket
- [x] Upload/download file CSV
- [x] Thống kê theo thành phố
- [x] Phân tích độ tuổi và lương
- [x] Tìm top earners
- [x] Export kết quả ra CSV

## Truy cập hệ thống

### MinIO Console (Web UI)
- URL: http://localhost:19001
- Username: `minio`
- Password: `minio123`

### MinIO API Endpoint
- URL: http://localhost:19000
- Access Key: `minio`
- Secret Key: `minio123`

## Các lệnh kubectl hữu ích

```bash
# Kiểm tra trạng thái
kubectl get pods -n datalake
kubectl get svc -n datalake
kubectl get statefulsets -n datalake

# Xem logs
kubectl logs minio-0 -n datalake

# Port forward
kubectl port-forward -n datalake svc/minio 19000:9000 19001:9001
```

## Các file được tạo
- `upload_csv_data.py`: Upload dữ liệu CSV lên MinIO
- `query_csv_pandas.py`: Truy vấn và phân tích dữ liệu
- `city_statistics.csv`: Thống kê theo thành phố
- `age_statistics.csv`: Thống kê theo độ tuổi
- `top_earners_by_city.csv`: Top earners mỗi thành phố

## Kiến trúc hệ thống

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Python App    │    │     Pandas      │    │      MinIO      │
│                 │────│                 │────│   (3 replicas)  │
│ - Upload CSV    │    │ - Query CSV     │    │ - Object Store  │
│ - Data Analysis │    │ - Analytics     │    │ - S3 Compatible │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                               │
                                               ▼
                                       ┌─────────────────┐
                                       │   Kubernetes    │
                                       │ - StatefulSet   │
                                       │ - Service       │
                                       │ - PVC Storage   │
                                       └─────────────────┘
```

## Tính năng đã hoàn thành
✅ MinIO cluster 3 replicas trên K8s  
✅ Lưu trữ dữ liệu CSV trên MinIO  
✅ Truy vấn và phân tích dữ liệu  
✅ Web console cho quản lý  
✅ S3-compatible API  
✅ Export kết quả phân tích