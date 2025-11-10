#!/bin/bash

# MongoDB Replica Set and Sharding Setup Script
# Following GeeksforGeeks tutorial methodology

echo "========================================="
echo "MongoDB Replication and Sharding Setup"
echo "Following GeeksforGeeks Tutorial"
echo "========================================="

# Wait for MongoDB containers to be ready
echo "Waiting for MongoDB containers to start..."
sleep 30

# Step 1: Initialize Config Server Replica Set
echo "Step 1: Initialize Config Server Replica Set (configReplSet)"
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

echo "Waiting for config server replica set to initialize..."
sleep 20

# Step 2: Initialize Shard 1 Replica Set (rs0)
echo "Step 2: Initialize Shard 1 Replica Set (rs0)"
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

echo "Waiting for shard 1 replica set to initialize..."
sleep 20

# Step 3: Initialize Shard 2 Replica Set (rs1)
echo "Step 3: Initialize Shard 2 Replica Set (rs1)"
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

echo "Waiting for shard 2 replica set to initialize..."
sleep 20

# Step 4: Add Shards to the Cluster (via Mongos)
echo "Step 4: Add Shards to the Cluster"
docker exec -it mongos mongosh --eval "
sh.addShard('rs0/mongo-shard1-primary:27017,mongo-shard1-secondary1:27017,mongo-shard1-secondary2:27017');
sh.addShard('rs1/mongo-shard2-primary:27017,mongo-shard2-secondary1:27017,mongo-shard2-secondary2:27017');
"

# Step 5: Verify Cluster Status
echo "Step 5: Verify Cluster Status"
docker exec -it mongos mongosh --eval "
print('=== Sharding Status ===');
sh.status();
"

echo "========================================="
echo "MongoDB Cluster Setup Complete!"
echo "========================================="
echo "Connection Information:"
echo "- Mongos Router: mongodb://localhost:27017"
echo "- Shard 1 Primary: mongodb://localhost:27022"
echo "- Shard 2 Primary: mongodb://localhost:27025"
echo "- Config Server 1: mongodb://localhost:27019"
echo "========================================="