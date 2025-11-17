# Week 11 - Kafka Cluster với Spring Boot

Dự án này thực hiện yêu cầu tạo 2 ứng dụng Spring Boot trao đổi dữ liệu JSON thông qua Kafka cluster 3 nodes, bao gồm kiểm tra leader và test failover.

## 🏗️ Kiến trúc Hệ thống

### Kafka Cluster (3 Brokers)
- **kafka1** (localhost:9092) - Broker ID: 1
- **kafka2** (localhost:9093) - Broker ID: 2  
- **kafka3** (localhost:9094) - Broker ID: 3
- **zookeeper** (localhost:2181) - Coordination service
- **kafka-ui** (localhost:8080) - Web UI monitoring

### Spring Boot Applications
- **Producer App** (localhost:8081) - Gửi JSON messages
- **Consumer App** (localhost:8082) - Nhận và xử lý JSON messages

## 📋 Cấu trúc Dự án

```
Week 11/
├── kafka-cluster/
│   └── docker-compose.yml      # Kafka cluster 3 nodes
├── producer-app/               # Spring Boot Producer
│   ├── pom.xml
│   └── src/main/java/com/example/producer/
│       ├── ProducerApplication.java
│       ├── model/UserMessage.java
│       ├── service/KafkaProducerService.java
│       └── controller/MessageController.java
├── consumer-app/               # Spring Boot Consumer  
│   ├── pom.xml
│   └── src/main/java/com/example/consumer/
│       ├── ConsumerApplication.java
│       ├── model/UserMessage.java
│       ├── service/KafkaConsumerService.java
│       └── controller/ConsumerController.java
├── scripts/
│   ├── setup-system.ps1       # Setup toàn bộ hệ thống
│   ├── check-cluster-status.ps1  # Kiểm tra cluster status
│   ├── test-leader-failover.ps1  # Test leader failover
│   └── cleanup.ps1            # Dọn dẹp hệ thống
└── README.md
```

## 🚀 Hướng dẫn Sử dụng

### Cách 1: Setup Tự động (Khuyến nghị)
```powershell
cd "d:\demo\BT-PTUDDN\Week 11\scripts"
.\setup-system.ps1
```

### Cách 2: Setup Thủ công

#### Bước 1: Khởi động Kafka Cluster
```powershell
cd "d:\demo\BT-PTUDDN\Week 11\kafka-cluster"
docker-compose up -d
```

#### Bước 2: Tạo Topic
```powershell
# Đợi Kafka sẵn sàng (30 giây)
docker exec kafka1 kafka-topics --bootstrap-server localhost:9092 --create --topic user-events --partitions 3 --replication-factor 3
```

#### Bước 3: Khởi động Producer App
```powershell
cd "..\producer-app"
mvn spring-boot:run
```

#### Bước 4: Khởi động Consumer App (Terminal mới)
```powershell
cd "..\consumer-app"  
mvn spring-boot:run
```

## 🧪 Kiểm tra và Testing

### 1. Kiểm tra Cluster Status
```powershell
cd scripts
.\check-cluster-status.ps1
```

### 2. Xác định Leader cho từng Partition
```powershell
docker exec kafka1 kafka-topics --bootstrap-server localhost:9092 --describe --topic user-events
```

### 3. Test Leader Failover
```powershell
.\test-leader-failover.ps1
```

Script này sẽ:
- Xác định broker nào đang là leader
- Gửi messages trước khi dừng leader
- Dừng broker leader
- Kiểm tra hệ thống có hoạt động bình thường không
- Khởi động lại broker và kiểm tra recovery

## 📡 API Endpoints

### Producer App (Port 8081)
- `POST /api/messages` - Gửi message
- `POST /api/messages/partition/{partition}` - Gửi message đến partition cụ thể
- `POST /api/messages/bulk?count=10` - Gửi nhiều messages
- `GET /api/health` - Health check

### Consumer App (Port 8082)
- `GET /api/health` - Health check
- `GET /api/stats` - Thống kê messages đã nhận
- `POST /api/stats/reset` - Reset thống kê

## 💬 Format JSON Message

```json
{
  "name": "John Doe",
  "email": "john@example.com", 
  "action": "CREATE",
  "data": "User registration data"
}
```

## 🔧 Test Commands

### Gửi Message qua cURL
```bash
curl -X POST http://localhost:8081/api/messages \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "action": "CREATE", 
    "data": "Test message"
  }'
```

### Gửi Bulk Messages
```bash
curl -X POST "http://localhost:8081/api/messages/bulk?count=50"
```

### Xem Statistics
```bash
curl http://localhost:8082/api/stats
```

## 🖥️ Monitoring

### Kafka UI
Truy cập: http://localhost:8080
- Xem cluster topology
- Monitor topics và partitions
- Xem consumer groups
- Real-time message flow

### Console Monitoring
```powershell
# Xem messages real-time
docker exec kafka1 kafka-console-consumer --bootstrap-server localhost:9092 --topic user-events --from-beginning

# Xem consumer group lag
docker exec kafka1 kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group user-events-group
```

## 🧨 Failover Testing

Script `test-leader-failover.ps1` thực hiện đầy đủ test case:

1. **Xác định Leader**: Tìm broker nào đang là leader cho partition 0
2. **Test Before**: Gửi messages khi cluster hoạt động bình thường
3. **Stop Leader**: Dừng broker leader
4. **Wait Election**: Đợi leader election (10 giây)
5. **Test During**: Gửi messages khi leader bị down → Hệ thống vẫn hoạt động
6. **Restart**: Khởi động lại broker đã dừng
7. **Test After**: Gửi messages sau khi recovery → Hệ thống hoạt động bình thường

## 📊 Kết quả Mong đợi

✅ **Hệ thống hoạt động bình thường** khi:
- Leader broker bị dừng
- Consumer vẫn nhận được messages
- Producer vẫn gửi được messages  
- Automatic leader election xảy ra
- Broker restart và rejoin cluster thành công

## 🧹 Cleanup

Để dọn dẹp toàn bộ hệ thống:
```powershell
cd scripts
.\cleanup.ps1
```

## 🎯 Đáp ứng Yêu cầu

✅ **2 ứng dụng Spring Boot trao đổi JSON**: Producer và Consumer apps

✅ **Kafka cluster 3 máy**: kafka1, kafka2, kafka3 với replication factor 3

✅ **Kiểm tra leader**: Script `check-cluster-status.ps1` và `kafka-topics --describe`

✅ **Test failover**: Script `test-leader-failover.ps1` dừng leader và kiểm tra hệ thống vẫn hoạt động

## 🔗 Tài nguyên

- **Kafka Documentation**: https://kafka.apache.org/documentation/
- **Spring Kafka**: https://spring.io/projects/spring-kafka
- **Docker Compose**: Kafka cluster configuration