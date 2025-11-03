# JMeter Load Test Scripts

## Mô tả
Thư mục này chứa các script JMeter để tạo load test nhằm trigger CPU alerts.

## Files
- `cpu-load-test.jmx` - JMeter test plan chính
- `run-load-test.ps1` - PowerShell script để chạy JMeter
- `README.md` - File này

## Cách sử dụng

### 1. Cài đặt JMeter
```powershell
# Download JMeter từ https://jmeter.apache.org/download_jmeter.cgi
# Giải nén và thêm vào PATH
```

### 2. Chạy Load Test
```powershell
# Chạy JMeter GUI mode để xem kết quả realtime
jmeter -t cpu-load-test.jmx

# Hoặc chạy headless mode
jmeter -n -t cpu-load-test.jmx -l results.jtl -e -o ./html-report
```

### 3. Chạy script PowerShell (được khuyến nghị)
```powershell
.\run-load-test.ps1
```

## Test Configuration

### Thread Group Settings:
- **Threads**: 50 concurrent users
- **Ramp-up**: 30 seconds
- **Duration**: 5 minutes (300 seconds)
- **Loops**: Infinite (trong thời gian duration)

### Test Scenarios:
1. **Course List Request**: GET `/` 
2. **Add Course Request**: GET `/addCourse`
3. **Constant Timer**: 100ms delay between requests

### Expected Results:
- Với 50 threads liên tục request trong 5 phút
- CPU usage của pods sẽ tăng lên > 80%
- Prometheus sẽ trigger alert sau 1 phút
- AlertManager sẽ gửi notification qua email/Slack/webhook

## Monitoring
Trong khi chạy load test, theo dõi:
```powershell
# CPU usage của pods
kubectl top pods -n default

# Prometheus metrics
curl http://localhost:30000/api/v1/query?query=rate(container_cpu_usage_seconds_total[1m])*100

# AlertManager alerts
curl http://localhost:30093/api/v1/alerts
```