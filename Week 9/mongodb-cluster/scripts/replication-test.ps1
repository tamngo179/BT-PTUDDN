# MongoDB Replication Testing Script
# Following GeeksforGeeks tutorial approach

Write-Host "=========================================" -ForegroundColor Green
Write-Host "MongoDB Replication Testing" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Test Shard 1 Replica Set (rs0)
Write-Host "Testing Shard 1 Replica Set (rs0)..." -ForegroundColor Yellow
docker exec -it mongo-shard1-primary mongosh --eval "
print('=== Shard 1 Replica Set Status ===');
rs.status();
print('');
print('=== Primary/Secondary Info ===');
rs.isMaster();
"

# Test Shard 2 Replica Set (rs1)
Write-Host "`nTesting Shard 2 Replica Set (rs1)..." -ForegroundColor Yellow
docker exec -it mongo-shard2-primary mongosh --eval "
print('=== Shard 2 Replica Set Status ===');
rs.status();
print('');
print('=== Primary/Secondary Info ===');
rs.isMaster();
"

# Test Config Server Replica Set
Write-Host "`nTesting Config Server Replica Set..." -ForegroundColor Yellow
docker exec -it mongo-config-1 mongosh --eval "
print('=== Config Server Replica Set Status ===');
rs.status();
"

# Test Read/Write Operations
Write-Host "`nTesting Read/Write Operations..." -ForegroundColor Yellow
docker exec -it mongos mongosh --eval "
use testReplication;

// Test write operation
print('=== Testing Write Operation ===');
db.test.insertOne({message: 'Hello from primary', timestamp: new Date()});
db.test.insertOne({message: 'Replication test', timestamp: new Date()});

// Display all data
print('=== Current Data ===');
db.test.find().pretty();

// Check which shard contains the data
print('=== Shard Distribution ===');
db.test.getShardDistribution();
"

# Test failover simulation (informational)
Write-Host "`nFailover Testing Information:" -ForegroundColor Cyan
Write-Host "To test failover manually:" -ForegroundColor White
Write-Host "1. Stop primary container: docker stop mongo-shard1-primary" -ForegroundColor White
Write-Host "2. Check replica set status: rs.status()" -ForegroundColor White
Write-Host "3. Observe automatic primary election" -ForegroundColor White
Write-Host "4. Restart stopped container: docker start mongo-shard1-primary" -ForegroundColor White

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Replication Testing Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green