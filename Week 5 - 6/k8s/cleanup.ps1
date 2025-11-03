# Clean up all deployed resources
Write-Host "=== Cleaning up Course Tracker and Monitoring Stack ===" -ForegroundColor Yellow

Write-Host "`n1. Removing Course Tracker application..." -ForegroundColor Yellow
kubectl delete -f k8s/ingress.yaml --ignore-not-found=true
kubectl delete -f k8s/service.yaml --ignore-not-found=true
kubectl delete -f k8s/deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/configmap.yaml --ignore-not-found=true

Write-Host "`n2. Removing Grafana..." -ForegroundColor Yellow
kubectl delete -f k8s/monitoring/grafana-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/monitoring/grafana-dashboard-config.yaml --ignore-not-found=true
kubectl delete -f k8s/monitoring/grafana-datasource-config.yaml --ignore-not-found=true

Write-Host "`n3. Removing Prometheus..." -ForegroundColor Yellow
kubectl delete -f k8s/monitoring/prometheus-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/monitoring/prometheus-config.yaml --ignore-not-found=true

Write-Host "`n4. Removing RBAC..." -ForegroundColor Yellow
kubectl delete -f k8s/monitoring/rbac.yaml --ignore-not-found=true

Write-Host "`n5. Removing monitoring namespace..." -ForegroundColor Yellow
kubectl delete -f k8s/monitoring/namespace.yaml --ignore-not-found=true

Write-Host "`n=== Cleanup completed! ===" -ForegroundColor Green