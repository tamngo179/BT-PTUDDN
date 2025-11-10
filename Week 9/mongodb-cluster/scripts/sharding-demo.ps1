# MongoDB Sharding Demo Script
# Following GeeksforGeeks tutorial approach

Write-Host "=========================================" -ForegroundColor Green
Write-Host "MongoDB Sharding Demo and Testing" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Enable sharding for a database and collection
Write-Host "Creating demo database and enabling sharding..." -ForegroundColor Yellow
docker exec -it mongos mongosh --eval "
// Create and use test database
use testDB;

// Enable sharding for the database
sh.enableSharding('testDB');

// Create a collection with sample data
db.users.insertMany([
  {_id: 1, name: 'Alice', age: 25, city: 'Hanoi'},
  {_id: 2, name: 'Bob', age: 30, city: 'Ho Chi Minh City'},
  {_id: 3, name: 'Charlie', age: 35, city: 'Da Nang'},
  {_id: 4, name: 'Diana', age: 28, city: 'Hai Phong'},
  {_id: 5, name: 'Eve', age: 32, city: 'Can Tho'}
]);

// Shard the collection using _id as shard key
sh.shardCollection('testDB.users', {'_id': 1});

// Display sharding status
print('=== Sharding Status ===');
sh.status();

// Show data distribution
print('=== Data Distribution ===');
db.users.getShardDistribution();
"

Write-Host "Inserting more test data..." -ForegroundColor Yellow
docker exec -it mongos mongosh --eval "
use testDB;

// Insert more data to trigger chunk migration
for(let i = 6; i <= 1000; i++) {
  db.users.insertOne({
    _id: i,
    name: 'User' + i,
    age: Math.floor(Math.random() * 50) + 18,
    city: ['Hanoi', 'Ho Chi Minh City', 'Da Nang', 'Hai Phong', 'Can Tho'][Math.floor(Math.random() * 5)]
  });
}

print('Inserted 1000 users total');
print('Current collection stats:');
db.users.count();

// Show final distribution
print('=== Final Data Distribution ===');
db.users.getShardDistribution();
"

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Sharding Demo Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green