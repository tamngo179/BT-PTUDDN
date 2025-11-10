# MongoDB Replica Set and Sharding Setup Script for Windows
# Following GeeksforGeeks tutorial methodology

Write-Host "=========================================" -ForegroundColor Green
Write-Host "MongoDB Replication and Sharding Setup" -ForegroundColor Green
Write-Host "Following GeeksforGeeks Tutorial" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Wait for MongoDB containers to be ready
Write-Host "Waiting for MongoDB containers to start..." -ForegroundColor Yellow
Start-Sleep 30

# Step 1: Initialize Config Server Replica Set
Write-Host "Step 1: Initialize Config Server Replica Set (configReplSet)" -ForegroundColor Cyan
docker exec -it mongo-config-1 mongosh --eval "
rs.initiate({
  _id: 'configReplSet',
  configsvr: true,
  members: [
    { _id: 0, host: 'mongo-config-1:27017' },
    { _id: 1, host: 'mongo-config-2:27017' },
    { _id: 2, host: 'mongo-config-3:27017' }
  ]
});
"

Write-Host "Waiting for config server replica set to initialize..." -ForegroundColor Yellow
Start-Sleep 20

# Step 2: Initialize Shard 1 Replica Set (rs0)
Write-Host "Step 2: Initialize Shard 1 Replica Set (rs0)" -ForegroundColor Cyan
docker exec -it mongo-shard1-primary mongosh --eval "
rs.initiate({
  _id: 'rs0',
  members: [
    { _id: 0, host: 'mongo-shard1-primary:27017' },
    { _id: 1, host: 'mongo-shard1-secondary1:27017' },
    { _id: 2, host: 'mongo-shard1-secondary2:27017' }
  ]
});
"

Write-Host "Waiting for shard 1 replica set to initialize..." -ForegroundColor Yellow
Start-Sleep 20

# Step 3: Initialize Shard 2 Replica Set (rs1)
Write-Host "Step 3: Initialize Shard 2 Replica Set (rs1)" -ForegroundColor Cyan
docker exec -it mongo-shard2-primary mongosh --eval "
rs.initiate({
  _id: 'rs1',
  members: [
    { _id: 0, host: 'mongo-shard2-primary:27017' },
    { _id: 1, host: 'mongo-shard2-secondary1:27017' },
    { _id: 2, host: 'mongo-shard2-secondary2:27017' }
  ]
});
"

Write-Host "Waiting for shard 2 replica set to initialize..." -ForegroundColor Yellow
Start-Sleep 20

# Step 4: Add Shards to the Cluster (via Mongos)
Write-Host "Step 4: Add Shards to the Cluster" -ForegroundColor Cyan
docker exec -it mongos mongosh --eval "
sh.addShard('rs0/mongo-shard1-primary:27017,mongo-shard1-secondary1:27017,mongo-shard1-secondary2:27017');
sh.addShard('rs1/mongo-shard2-primary:27017,mongo-shard2-secondary1:27017,mongo-shard2-secondary2:27017');
"

# Step 5: Verify Cluster Status
Write-Host "Step 5: Verify Cluster Status" -ForegroundColor Cyan
docker exec -it mongos mongosh --eval "
print('=== Sharding Status ===');
sh.status();
"

Write-Host "=========================================" -ForegroundColor Green
Write-Host "MongoDB Cluster Setup Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Connection Information:" -ForegroundColor Yellow
Write-Host "- Mongos Router: mongodb://localhost:27017" -ForegroundColor White
Write-Host "- Shard 1 Primary: mongodb://localhost:27022" -ForegroundColor White
Write-Host "- Shard 2 Primary: mongodb://localhost:27025" -ForegroundColor White
Write-Host "- Config Server 1: mongodb://localhost:27019" -ForegroundColor White
Write-Host "=========================================" -ForegroundColor Green