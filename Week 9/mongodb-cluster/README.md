# MongoDB - Replication and Sharding

## 🏗️ Kiến trúc Cluster

Dự án này triển khai một MongoDB cluster hoàn chỉnh với:

### Config Servers (configReplSet)
- `mongo-config-1` (cổng 27019)
- `mongo-config-2` (cổng 27020) 
- `mongo-config-3` (cổng 27021)

### Shard 1 (rs0) - Replica Set
- `mongo-shard1-primary` - Primary node (cổng 27022)
- `mongo-shard1-secondary1` - Secondary node (cổng 27023)
- `mongo-shard1-secondary2` - Secondary node (cổng 27024)

### Shard 2 (rs1) - Replica Set
- `mongo-shard2-primary` - Primary node (cổng 27025)
- `mongo-shard2-secondary1` - Secondary node (cổng 27026)
- `mongo-shard2-secondary2` - Secondary node (cổng 27027)

### Mongos Router
- `mongos` - Query Router (cổng 27017)

## 📊 Sơ đồ Kiến trúc

```
                    🌐 Client Applications
                           |
                    📡 Mongos Router
                      (Port 27017)
                           |
           ┌───────────────┼───────────────┐
           |                               |
    🗂️ Shard 1 (rs0)               🗂️ Shard 2 (rs1)
    ┌─────────────────┐            ┌─────────────────┐
    │ Primary (27022) │            │ Primary (27025) │
    │ Second1 (27023) │            │ Second1 (26026) │
    │ Second2 (27024) │            │ Second2 (27027) │
    └─────────────────┘            └─────────────────┘
                           |
               ⚙️ Config Server Replica Set
                    ┌─────────────────┐
                    │ Config1 (27019) │
                    │ Config2 (27020) │
                    │ Config3 (27021) │
                    └─────────────────┘
```

### Replication Process Flow
```
Primary Node          Secondary Nodes
     │                      │
     │  1. Write Operation  │
     │ ──────────────────►  │
     │                      │
     │  2. Oplog Entry      │
     │ ──────────────────►  │
     │                      │
     │  3. Data Replication │
     │ ──────────────────►  │
     │                      │
     │ ◄────────────────── │
     │   4. Acknowledgment  │
```

### Sharding Data Distribution
```
Original Data:        After Sharding:
┌─────────────┐      ┌──────────┐  ┌──────────┐
│   Users     │      │ Users    │  │ Users    │
│ ID: 1-1000  │ ──►  │ ID: 1-500│  │ID:501-1000│
│             │      │ (Shard 1)│  │ (Shard 2)│
└─────────────┘      └──────────┘  └──────────┘
```

##  Setup

### Bước 1: Khởi động Cluster
```powershell
# Khởi động tất cả containers
docker-compose up -d

# Kiểm tra trạng thái containers
docker-compose ps
```

### Bước 2: Khởi tạo Replica Sets và Sharding
```powershell
# Chạy script tự động (Windows)
.\scripts\create_replicaset.ps1

# Hoặc cho Linux/macOS
chmod +x ./scripts/create_replicaset.sh
./scripts/create_replicaset.sh
```

### Bước 3: Kiểm tra trạng thái Cluster
```powershell
.\scripts\check-status.ps1
```

### Bước 4: Test Sharding (Tùy chọn)
```powershell
.\scripts\sharding-demo.ps1
```

### Bước 5: Test Replication (Tùy chọn)
```powershell
.\scripts\replication-test.ps1
```

## 🔗 Kết nối tới Cluster

### Connection Strings
- **Mongos Router (khuyến nghị)**: `mongodb://localhost:27017`
- **Shard 1 Primary**: `mongodb://localhost:27022`
- **Shard 2 Primary**: `mongodb://localhost:27025`
- **Config Server 1**: `mongodb://localhost:27019`

### Kết nối bằng MongoDB Shell
```bash
# Kết nối qua Mongos Router
mongosh mongodb://localhost:27017

# Kết nối trực tiếp tới shard
mongosh mongodb://localhost:27022
```

## 🗂️ Cấu trúc Files

```
mongodb-cluster/
├── docker-compose.yml              # Docker composition
├── scripts/
│   ├── create_replicaset.ps1      # Setup script (Windows)
│   ├── create_replicaset.sh       # Setup script (Linux/macOS)
│   ├── sharding-demo.ps1          # Sharding demo
│   ├── replication-test.ps1       # Replication testing
│   └── check-status.ps1           # Status checking
├── config/                        # Configuration files
└── README.md                      # Documentation
```

## 🖼️ Hình ảnh và Visualization

### 1. Xem sơ đồ kiến trúc
Các sơ đồ ASCII đã được tích hợp trong README này ở phần trên.

### 2. MongoDB Compass - GUI Tool
Để xem cluster trực quan, bạn có thể sử dụng MongoDB Compass:
- Tải về: https://www.mongodb.com/products/compass
- Kết nối: `mongodb://localhost:27017`

### 3. Giám sát cluster qua Web UI
```powershell
# Khởi động MongoDB với monitoring
docker run -d -p 8080:8080 --network mongodb-cluster_mongo-cluster \
  --name mongo-express \
  -e ME_CONFIG_MONGODB_URL="mongodb://mongos:27017" \
  mongo-express
```
Truy cập: http://localhost:8080

### 4. Hình ảnh tham khảo từ GeeksforGeeks
- MongoDB Replication: https://media.geeksforgeeks.org/wp-content/uploads/20250328180638078456/mongo_db.webp
- Sharding Architecture: https://media.geeksforgeeks.org/wp-content/uploads/20211018193137/shard.jpg

### 5. Interactive Visual Dashboard
```powershell
# Khởi động dashboard tương tác với sơ đồ
.\scripts\visual-dashboard.ps1
```

### 6. Real-time Status Dashboard
```powershell
# Xem status liên tục
while ($true) { 
    Clear-Host
    .\scripts\check-status.ps1
    Start-Sleep 5 
}
```

## 🎯 Cách xem hình ảnh và visualization

### Trong VS Code:
1. **Markdown Preview**: Nhấn `Ctrl+Shift+V` để xem README với sơ đồ ASCII
2. **File Explorer**: Các sơ đồ được hiển thị trực tiếp trong README.md

### Qua Browser:
1. **GitHub**: Push code lên GitHub và xem README online
2. **MongoDB Compass**: GUI tool chuyên dụng
3. **Mongo Express**: Web interface tại http://localhost:8080

### Interactive Dashboard:
```powershell
# Chạy dashboard với sơ đồ màu sắc
.\scripts\visual-dashboard.ps1
```