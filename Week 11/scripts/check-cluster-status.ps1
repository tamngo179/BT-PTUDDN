# Kafka Cluster Status Check Script

Write-Host "========================================="  -ForegroundColor Green
Write-Host "KAFKA CLUSTER STATUS CHECK"  -ForegroundColor Green
Write-Host "========================================="  -ForegroundColor Green

# Check if containers are running
Write-Host "Checking Docker containers..." -ForegroundColor Yellow
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | Select-String -Pattern "kafka|zookeeper"

Write-Host "`nChecking Kafka brokers..." -ForegroundColor Yellow

# List brokers
Write-Host "\n1. KAFKA BROKERS:" -ForegroundColor Cyan
docker exec kafka1 kafka-broker-api-versions --bootstrap-server localhost:9092 | Select-String "id"

# List topics with partition and leader info
Write-Host "\n2. TOPICS AND LEADERS:" -ForegroundColor Cyan
docker exec kafka1 kafka-topics --bootstrap-server localhost:9092 --list

Write-Host "\n3. TOPIC DETAILS (user-events):" -ForegroundColor Cyan
docker exec kafka1 kafka-topics --bootstrap-server localhost:9092 --describe --topic user-events

# Check cluster metadata
Write-Host "\n4. CLUSTER METADATA:" -ForegroundColor Cyan
docker exec kafka1 kafka-metadata-shell --snapshot /tmp/kraft-combined-logs/__cluster_metadata-0/00000000000000000000.log --print-brokers 2>$null

# Check consumer groups
Write-Host "\n5. CONSUMER GROUPS:" -ForegroundColor Cyan
docker exec kafka1 kafka-consumer-groups --bootstrap-server localhost:9092 --list

Write-Host "\n6. CONSUMER GROUP DETAILS:" -ForegroundColor Cyan
docker exec kafka1 kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group user-events-group 2>$null

Write-Host "\n========================================="  -ForegroundColor Green
Write-Host "STATUS CHECK COMPLETE"  -ForegroundColor Green
Write-Host "========================================="  -ForegroundColor Green