# MongoDB Cluster Status Check Script
# Following GeeksforGeeks tutorial approach

Write-Host "=========================================" -ForegroundColor Green
Write-Host "MongoDB Cluster Status Check" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Check overall cluster status
Write-Host "Checking Overall Cluster Status..." -ForegroundColor Yellow
docker exec -it mongos mongosh --eval "
print('=== Cluster Sharding Status ===');
sh.status();
print('');
print('=== Available Databases ===');
show dbs;
"

# Check individual replica sets
Write-Host "`nChecking Individual Replica Sets..." -ForegroundColor Yellow

Write-Host "Config Server Replica Set:" -ForegroundColor Cyan
docker exec -it mongo-config-1 mongosh --eval "
print('Config Server RS Status:');
rs.status();
"

Write-Host "`nShard 1 Replica Set (rs0):" -ForegroundColor Cyan
docker exec -it mongo-shard1-primary mongosh --eval "
print('Shard 1 RS Status:');
rs.status();
"

Write-Host "`nShard 2 Replica Set (rs1):" -ForegroundColor Cyan
docker exec -it mongo-shard2-primary mongosh --eval "
print('Shard 2 RS Status:');
rs.status();
"

# Check container health
Write-Host "`nChecking Container Health..." -ForegroundColor Yellow
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | Select-String "mongo"

Write-Host "`nChecking Resource Usage..." -ForegroundColor Yellow
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" | Select-String "mongo"

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Status Check Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

Write-Host "Connection URLs:" -ForegroundColor Yellow
Write-Host "- Mongos Router (Main): mongodb://localhost:27017" -ForegroundColor White
Write-Host "- Shard 1 Primary: mongodb://localhost:27022" -ForegroundColor White
Write-Host "- Shard 2 Primary: mongodb://localhost:27025" -ForegroundColor White
Write-Host "- Config Server 1: mongodb://localhost:27019" -ForegroundColor White