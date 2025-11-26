#!/usr/bin/env python3
"""
Script để truy vấn dữ liệu CSV đã tải xuống từ MinIO sử dụng DuckDB
"""

import boto3
import pandas as pd
import os
from botocore.exceptions import ClientError

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

def download_csv_from_minio(s3_client, file_name, local_path):
    """Tải file CSV từ MinIO về local"""
    try:
        s3_client.download_file(BUCKET_NAME, file_name, local_path)
        print(f"Đã tải '{file_name}' về '{local_path}' thành công")
        return True
    except ClientError as e:
        print(f"Lỗi khi tải file: {e}")
        return False

def query_csv_with_pandas(file_path):
    """Truy vấn dữ liệu CSV sử dụng Pandas"""
    try:
        # Đọc dữ liệu CSV
        df = pd.read_csv(file_path)
        
        print(f"=== Thông tin dữ liệu ===")
        print(f"Số dòng: {len(df)}")
        print(f"Số cột: {len(df.columns)}")
        print(f"Cột: {list(df.columns)}")
        
        # Query 1: Hiển thị 10 dòng đầu
        print("\n=== Query 1: 10 dòng đầu ===")
        print(df.head(10))
        
        # Query 2: Thống kê theo thành phố
        print("\n=== Query 2: Thống kê theo thành phố ===")
        city_stats = df.groupby('city').agg({
            'id': 'count',
            'age': 'mean',
            'salary': 'mean'
        }).rename(columns={'id': 'count', 'age': 'avg_age', 'salary': 'avg_salary'})
        city_stats = city_stats.round(2).sort_values('avg_salary', ascending=False)
        print(city_stats)
        
        # Query 3: Top 5 lương cao nhất
        print("\n=== Query 3: Top 5 lương cao nhất ===")
        top_salary = df.nlargest(5, 'salary')[['name', 'city', 'age', 'salary']]
        print(top_salary)
        
        # Query 4: Phân tích độ tuổi
        print("\n=== Query 4: Phân tích độ tuổi ===")
        df['age_group'] = pd.cut(df['age'], 
                               bins=[0, 25, 35, 45, 100], 
                               labels=['Under 25', '25-34', '35-44', '45+'])
        
        age_stats = df.groupby('age_group').agg({
            'id': 'count',
            'salary': ['mean', 'min', 'max']
        }).round(2)
        age_stats.columns = ['count', 'avg_salary', 'min_salary', 'max_salary']
        print(age_stats)
        
        # Query 5: User có lương cao nhất mỗi thành phố
        print("\n=== Query 5: User có lương cao nhất mỗi thành phố ===")
        max_salary_by_city = df.loc[df.groupby('city')['salary'].idxmax()][['name', 'city', 'age', 'salary']]
        max_salary_by_city = max_salary_by_city.sort_values('salary', ascending=False)
        print(max_salary_by_city)
        
        # Xuất kết quả ra file
        print("\n=== Export kết quả ===")
        city_stats.to_csv('city_statistics.csv')
        age_stats.to_csv('age_statistics.csv')
        max_salary_by_city.to_csv('top_earners_by_city.csv', index=False)
        print("Đã xuất các file thống kê:")
        print("- city_statistics.csv")
        print("- age_statistics.csv")
        print("- top_earners_by_city.csv")
        
    except Exception as e:
        print(f"Lỗi khi xử lý dữ liệu: {e}")

def main():
    """Main function"""
    print("=== Query CSV Data from MinIO using Pandas ===")
    
    # Tạo S3 client
    s3_client = create_s3_client()
    
    # Tải file CSV từ MinIO
    local_file = 'downloaded_sample_data.csv'
    if download_csv_from_minio(s3_client, 'sample_data.csv', local_file):
        # Truy vấn dữ liệu
        query_csv_with_pandas(local_file)
    
    print("\n=== Hoàn thành! ===")

if __name__ == "__main__":
    main()