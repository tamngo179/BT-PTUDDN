# Kafka System Setup Script

Write-Host "========================================="  -ForegroundColor Green
Write-Host "KAFKA SYSTEM SETUP"  -ForegroundColor Green
Write-Host "========================================="  -ForegroundColor Green

# Check Docker
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    docker version | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker not found. Please install and start Docker." -ForegroundColor Red
    exit 1
}

# Step 1: Start Kafka cluster
Write-Host "\nStep 1: Starting Kafka cluster..." -ForegroundColor Cyan
Set-Location "..\kafka-cluster"
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Kafka cluster started" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to start Kafka cluster" -ForegroundColor Red
    exit 1
}

# Wait for Kafka to be ready
Write-Host "\nWaiting for Kafka cluster to be ready..." -ForegroundColor Yellow
Start-Sleep 30

# Step 2: Create topic
Write-Host "\nStep 2: Creating topic 'user-events'..." -ForegroundColor Cyan
docker exec kafka1 kafka-topics --bootstrap-server localhost:9092 --create --topic user-events --partitions 3 --replication-factor 3 --if-not-exists

# Step 3: Verify topic
Write-Host "\nStep 3: Verifying topic creation..." -ForegroundColor Cyan
docker exec kafka1 kafka-topics --bootstrap-server localhost:9092 --describe --topic user-events

# Step 4: Start Producer app
Write-Host "\nStep 4: Starting Producer application..." -ForegroundColor Cyan
Set-Location "..\producer-app"
Start-Process powershell -ArgumentList "-Command", "mvn spring-boot:run" -WindowStyle Minimized
Write-Host "✓ Producer app starting on port 8081" -ForegroundColor Green

# Step 5: Start Consumer app
Write-Host "\nStep 5: Starting Consumer application..." -ForegroundColor Cyan
Set-Location "..\consumer-app"
Start-Process powershell -ArgumentList "-Command", "mvn spring-boot:run" -WindowStyle Minimized
Write-Host "✓ Consumer app starting on port 8082" -ForegroundColor Green

# Wait for apps to start
Write-Host "\nWaiting for applications to start..." -ForegroundColor Yellow
Start-Sleep 45

# Step 6: Test the system
Write-Host "\nStep 6: Testing the system..." -ForegroundColor Cyan
$testMessage = @{
    id = [System.Guid]::NewGuid().ToString()
    name = "Setup Test User"
    email = "setup@example.com"
    action = "CREATE"
    data = "System setup test message"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8081/api/messages" -Method POST -Body $testMessage -ContentType "application/json"
    Write-Host "✓ Test message sent successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠ Producer app may still be starting..." -ForegroundColor Yellow
}

# Step 7: Show access URLs
Write-Host "\n========================================="  -ForegroundColor Green
Write-Host "SETUP COMPLETE"  -ForegroundColor Green
Write-Host "========================================="  -ForegroundColor Green

Write-Host "\n🎯 Access URLs:" -ForegroundColor Yellow
Write-Host "• Producer API: http://localhost:8081/api/health" -ForegroundColor White
Write-Host "• Consumer API: http://localhost:8082/api/health" -ForegroundColor White
Write-Host "• Kafka UI: http://localhost:8080" -ForegroundColor White

Write-Host "\n📋 Useful Commands:" -ForegroundColor Yellow
Write-Host "• Check status: .\scripts\check-cluster-status.ps1" -ForegroundColor White
Write-Host "• Test failover: .\scripts\test-leader-failover.ps1" -ForegroundColor White
Write-Host "• Send message: POST http://localhost:8081/api/messages" -ForegroundColor White
Write-Host "• View stats: GET http://localhost:8082/api/stats" -ForegroundColor White

Write-Host "\n📝 Sample JSON message:" -ForegroundColor Yellow
Write-Host @'
{
  "name": "John Doe",
  "email": "john@example.com",
  "action": "CREATE",
  "data": "User registration"
}
'@ -ForegroundColor Gray

Set-Location "..\scripts"