#!/usr/bin/env python3
"""
Script để upload dữ liệu CSV lên MinIO
"""

import boto3
from botocore.exceptions import ClientError
import pandas as pd
import os

# MinIO configuration
MINIO_ENDPOINT = 'http://localhost:19000'
MINIO_ACCESS_KEY = 'minio'
MINIO_SECRET_KEY = 'minio123'
BUCKET_NAME = 'csv-data'

def create_s3_client():
    """Tạo S3 client để kết nối với MinIO"""
    return boto3.client(
        's3',
        endpoint_url=MINIO_ENDPOINT,
        aws_access_key_id=MINIO_ACCESS_KEY,
        aws_secret_access_key=MINIO_SECRET_KEY,
        region_name='us-east-1'
    )

def create_bucket(s3_client, bucket_name):
    """Tạo bucket nếu chưa tồn tại"""
    try:
        s3_client.head_bucket(Bucket=bucket_name)
        print(f"Bucket '{bucket_name}' đã tồn tại")
    except ClientError:
        try:
            s3_client.create_bucket(Bucket=bucket_name)
            print(f"Đã tạo bucket '{bucket_name}' thành công")
        except ClientError as e:
            print(f"Lỗi khi tạo bucket: {e}")

def create_sample_csv():
    """Tạo file CSV mẫu để test"""
    data = {
        'id': range(1, 101),
        'name': [f'User_{i}' for i in range(1, 101)],
        'age': [20 + (i % 50) for i in range(1, 101)],
        'city': ['Hanoi', 'HCM', 'Danang', 'Haiphong', 'Cantho'] * 20,
        'salary': [30000 + (i * 100) for i in range(1, 101)]
    }
    
    df = pd.DataFrame(data)
    df.to_csv('sample_data.csv', index=False)
    print("Đã tạo file sample_data.csv")
    return 'sample_data.csv'

def upload_file(s3_client, file_name, bucket_name, object_name=None):
    """Upload file lên MinIO"""
    if object_name is None:
        object_name = os.path.basename(file_name)
    
    try:
        s3_client.upload_file(file_name, bucket_name, object_name)
        print(f"Đã upload '{file_name}' thành công lên bucket '{bucket_name}'")
        return True
    except ClientError as e:
        print(f"Lỗi khi upload file: {e}")
        return False

def main():
    """Main function"""
    print("=== Upload CSV Data to MinIO ===")
    
    # Tạo S3 client
    s3_client = create_s3_client()
    
    # Tạo bucket
    create_bucket(s3_client, BUCKET_NAME)
    
    # Tạo và upload file CSV mẫu
    csv_file = create_sample_csv()
    upload_file(s3_client, csv_file, BUCKET_NAME)
    
    # List files in bucket
    try:
        response = s3_client.list_objects_v2(Bucket=BUCKET_NAME)
        if 'Contents' in response:
            print(f"\nFiles trong bucket '{BUCKET_NAME}':")
            for obj in response['Contents']:
                print(f"  - {obj['Key']} (Size: {obj['Size']} bytes)")
        else:
            print(f"Bucket '{BUCKET_NAME}' trống")
    except ClientError as e:
        print(f"Lỗi khi list objects: {e}")

if __name__ == "__main__":
    main()