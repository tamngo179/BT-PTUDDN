#!/usr/bin/env python3
"""
Script để truy vấn dữ liệu CSV từ MinIO sử dụng DuckDB
"""

import duckdb
import pandas as pd

# MinIO configuration
MINIO_ENDPOINT = 'http://localhost:19000'
MINIO_ACCESS_KEY = 'minio'
MINIO_SECRET_KEY = 'minio123'
BUCKET_NAME = 'csv-data'

def setup_duckdb_s3():
    """Cấu hình DuckDB để kết nối với MinIO S3"""
    conn = duckdb.connect()
    
    # Install và load httpfs extension
    conn.execute("INSTALL httpfs;")
    conn.execute("LOAD httpfs;")
    
    # Cấu hình S3 credentials
    conn.execute(f"SET s3_endpoint='{MINIO_ENDPOINT}';")
    conn.execute(f"SET s3_access_key_id='{MINIO_ACCESS_KEY}';")
    conn.execute(f"SET s3_secret_access_key='{MINIO_SECRET_KEY}';")
    conn.execute("SET s3_use_ssl=false;")
    conn.execute("SET s3_url_style='path';")
    
    return conn

def query_csv_data(conn, file_name):
    """Truy vấn dữ liệu CSV từ MinIO"""
    s3_url = f"s3://{BUCKET_NAME}/{file_name}"
    
    print(f"Đang truy vấn dữ liệu từ: {s3_url}")
    
    try:
        # Query 1: Đọc toàn bộ dữ liệu
        print("\n=== Query 1: Toàn bộ dữ liệu (10 dòng đầu) ===")
        query1 = f"SELECT * FROM '{s3_url}' LIMIT 10"
        result1 = conn.execute(query1).fetchdf()
        print(result1)
        
        # Query 2: Thống kê theo thành phố
        print("\n=== Query 2: Thống kê theo thành phố ===")
        query2 = f"""
        SELECT 
            city,
            COUNT(*) as count,
            AVG(age) as avg_age,
            AVG(salary) as avg_salary
        FROM '{s3_url}'
        GROUP BY city
        ORDER BY avg_salary DESC
        """
        result2 = conn.execute(query2).fetchdf()
        print(result2)
        
        # Query 3: Tìm user có lương cao nhất mỗi thành phố
        print("\n=== Query 3: User có lương cao nhất mỗi thành phố ===")
        query3 = f"""
        WITH ranked_users AS (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY city ORDER BY salary DESC) as rn
            FROM '{s3_url}'
        )
        SELECT id, name, age, city, salary
        FROM ranked_users
        WHERE rn = 1
        ORDER BY salary DESC
        """
        result3 = conn.execute(query3).fetchdf()
        print(result3)
        
        # Query 4: Phân tích độ tuổi
        print("\n=== Query 4: Phân tích độ tuổi ===")
        query4 = f"""
        SELECT 
            CASE 
                WHEN age < 25 THEN 'Under 25'
                WHEN age < 35 THEN '25-34'
                WHEN age < 45 THEN '35-44'
                ELSE '45+'
            END as age_group,
            COUNT(*) as count,
            AVG(salary) as avg_salary,
            MIN(salary) as min_salary,
            MAX(salary) as max_salary
        FROM '{s3_url}'
        GROUP BY age_group
        ORDER BY avg_salary
        """
        result4 = conn.execute(query4).fetchdf()
        print(result4)
        
    except Exception as e:
        print(f"Lỗi khi truy vấn dữ liệu: {e}")

def create_view_and_advanced_queries(conn):
    """Tạo view và thực hiện các truy vấn nâng cao"""
    s3_url = f"s3://{BUCKET_NAME}/sample_data.csv"
    
    try:
        # Tạo view từ S3 data
        print("\n=== Tạo View từ dữ liệu S3 ===")
        conn.execute(f"""
        CREATE OR REPLACE VIEW users_view AS
        SELECT * FROM '{s3_url}'
        """)
        
        # Truy vấn từ view
        print("\n=== Query từ View: Top 5 lương cao nhất ===")
        result = conn.execute("""
        SELECT name, city, age, salary
        FROM users_view
        ORDER BY salary DESC
        LIMIT 5
        """).fetchdf()
        print(result)
        
        # Export kết quả ra CSV
        print("\n=== Export kết quả truy vấn ra file ===")
        conn.execute("""
        COPY (
            SELECT city, COUNT(*) as user_count, AVG(salary) as avg_salary
            FROM users_view
            GROUP BY city
            ORDER BY avg_salary DESC
        ) TO 'city_stats.csv' (HEADER, DELIMITER ',')
        """)
        print("Đã export kết quả ra file 'city_stats.csv'")
        
    except Exception as e:
        print(f"Lỗi khi tạo view hoặc truy vấn nâng cao: {e}")

def main():
    """Main function"""
    print("=== Query CSV Data from MinIO using DuckDB ===")
    
    # Setup DuckDB with S3 support
    conn = setup_duckdb_s3()
    
    # Query CSV data
    query_csv_data(conn, 'sample_data.csv')
    
    # Advanced queries with views
    create_view_and_advanced_queries(conn)
    
    # Đóng connection
    conn.close()
    print("\n=== Hoàn thành! ===")

if __name__ == "__main__":
    main()