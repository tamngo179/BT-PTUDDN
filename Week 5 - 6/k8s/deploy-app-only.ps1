# Build and deploy just the Course Tracker application
Write-Host "=== Building and Deploying Course Tracker Application ===" -ForegroundColor Green

# Build the Docker image
Write-Host "`n1. Building Docker image..." -ForegroundColor Yellow
docker build -t course-tracker:latest .

# Tag for your registry (update with your registry)
Write-Host "`n2. Tagging image..." -ForegroundColor Yellow
docker tag course-tracker:latest ghcr.io/tamngo179/course-tracker:latest

# Push to registry (uncomment if you want to push)
# Write-Host "`n3. Pushing to registry..." -ForegroundColor Yellow
# docker push ghcr.io/tamngo179/course-tracker:latest

# Deploy to Kubernetes
Write-Host "`n4. Deploying to Kubernetes..." -ForegroundColor Yellow
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

Write-Host "`n5. Waiting for deployment..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/course-tracker-deployment

Write-Host "`n=== Application deployed successfully! ===" -ForegroundColor Green
kubectl get pods
kubectl get services