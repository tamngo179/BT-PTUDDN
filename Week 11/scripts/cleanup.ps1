# Kafka System Cleanup Script

Write-Host "========================================="  -ForegroundColor Red
Write-Host "KAFKA SYSTEM CLEANUP"  -ForegroundColor Red
Write-Host "========================================="  -ForegroundColor Red

# Stop Spring Boot applications
Write-Host "Stopping Spring Boot applications..." -ForegroundColor Yellow
Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*spring-boot*" } | Stop-Process -Force
Write-Host "✓ Spring Boot applications stopped" -ForegroundColor Green

# Stop and remove Docker containers
Write-Host "\nStopping Kafka cluster..." -ForegroundColor Yellow
Set-Location "..\kafka-cluster"
docker-compose down -v

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Kafka cluster stopped and volumes removed" -ForegroundColor Green
} else {
    Write-Host "⚠ Some containers may still be running" -ForegroundColor Yellow
}

# Remove any remaining Kafka containers
Write-Host "\nRemoving any remaining containers..." -ForegroundColor Yellow
docker ps -a --format "{{.Names}}" | Where-Object { $_ -match "kafka|zookeeper" } | ForEach-Object {
    docker rm -f $_ 2>$null
}

# Clean up networks
Write-Host "\nCleaning up networks..." -ForegroundColor Yellow
docker network ls --format "{{.Name}}" | Where-Object { $_ -match "kafka" } | ForEach-Object {
    docker network rm $_ 2>$null
}

# Show final status
Write-Host "\nFinal status check..." -ForegroundColor Yellow
$remainingContainers = docker ps -a --format "{{.Names}}" | Where-Object { $_ -match "kafka|zookeeper" }
if ($remainingContainers) {
    Write-Host "⚠ Remaining containers: $($remainingContainers -join ', ')" -ForegroundColor Yellow
} else {
    Write-Host "✓ All containers cleaned up" -ForegroundColor Green
}

Write-Host "\n========================================="  -ForegroundColor Red
Write-Host "CLEANUP COMPLETE"  -ForegroundColor Red
Write-Host "========================================="  -ForegroundColor Red

Set-Location "..\scripts"