# K8s Data Lake với MinIO

Data Lake sử dụng MinIO trên Kubernetes để lưu trữ và truy vấn dữ liệu CSV.

## Screenshots

### MinIO StatefulSet với 3 replicas
![MinIO StatefulSet](picture/Minio%20StatefulSet%20succeed%20with%203%20replicas.png)

### MinIO Console Web UI
![Web Console](picture/web%20console.png)

### MinIO Ready
![MinIO Ready](picture/MinIO%20ready.png)

## Triển khai

```bash
# Tạo namespace
kubectl create namespace datalake

# Triển khai MinIO
kubectl apply -f minio-secret.yaml
kubectl apply -f minio-service.yaml
kubectl apply -f minio-statefulset.yaml

# Port forward
kubectl port-forward -n datalake svc/minio 19000:9000 19001:9001
```

## Sử dụng

```bash
# Cài đặt dependencies
pip install boto3 pandas

# Upload dữ liệu CSV
python upload_csv_data.py

# Truy vấn dữ liệu
python query_csv_pandas.py
```

## Truy cập

- **MinIO Console**: http://localhost:19001
- **API Endpoint**: http://localhost:19000
- **Login**: minio / minio123

## Kiến trúc

- 3 MinIO replicas với persistent storage
- S3-compatible API
- Tích hợp Pandas để phân tích CSV