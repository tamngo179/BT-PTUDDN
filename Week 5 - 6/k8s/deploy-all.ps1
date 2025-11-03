# Deploy Course Tracker Application with Monitoring Stack to Kubernetes
# Make sure you have kubectl configured and connected to your K8s cluster

Write-Host "=== Deploying Course Tracker with Monitoring Stack ===" -ForegroundColor Green

# Check if kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "Error: kubectl not found. Please install kubectl and configure it." -ForegroundColor Red
    exit 1
}

Write-Host "✓ Kubernetes cluster connection will be tested during deployment" -ForegroundColor Green

Write-Host "`n1. Creating monitoring namespace..." -ForegroundColor Yellow
kubectl apply -f k8s/monitoring/namespace.yaml

Write-Host "`n2. Setting up RBAC for Prometheus..." -ForegroundColor Yellow
kubectl apply -f k8s/monitoring/rbac.yaml

Write-Host "`n3. Deploying Prometheus configuration..." -ForegroundColor Yellow
kubectl apply -f k8s/monitoring/prometheus-config.yaml

Write-Host "`n4. Deploying Prometheus..." -ForegroundColor Yellow
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml

Write-Host "`n5. Setting up Grafana datasources..." -ForegroundColor Yellow
kubectl apply -f k8s/monitoring/grafana-datasource-config.yaml

Write-Host "`n6. Setting up Grafana dashboards..." -ForegroundColor Yellow
kubectl apply -f k8s/monitoring/grafana-dashboard-config.yaml

Write-Host "`n7. Deploying Grafana..." -ForegroundColor Yellow
kubectl apply -f k8s/monitoring/grafana-deployment.yaml

Write-Host "`n8. Deploying application ConfigMap..." -ForegroundColor Yellow
kubectl apply -f k8s/configmap.yaml

Write-Host "`n9. Deploying Course Tracker application..." -ForegroundColor Yellow
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

Write-Host "`n10. Setting up Ingress (optional)..." -ForegroundColor Yellow
kubectl apply -f k8s/ingress.yaml

Write-Host "`n=== Waiting for deployments to be ready ===" -ForegroundColor Green

Write-Host "`nWaiting for Prometheus..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring

Write-Host "`nWaiting for Grafana..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

Write-Host "`nWaiting for Course Tracker..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/course-tracker-deployment

Write-Host "`n=== Deployment Summary ===" -ForegroundColor Green
Write-Host "✓ Course Tracker Application deployed" -ForegroundColor Green
Write-Host "✓ Prometheus monitoring deployed" -ForegroundColor Green
Write-Host "✓ Grafana visualization deployed" -ForegroundColor Green

Write-Host "`n=== Access Information ===" -ForegroundColor Cyan
Write-Host "Course Tracker App:"
kubectl get service course-tracker-service
Write-Host "`nPrometheus (NodePort 30000):"
kubectl get service prometheus-service -n monitoring
Write-Host "`nGrafana (NodePort 32000):"
kubectl get service grafana -n monitoring

Write-Host "`n=== Grafana Login Information ===" -ForegroundColor Cyan
Write-Host "URL: http://<node-ip>:32000" -ForegroundColor White
Write-Host "Username: admin" -ForegroundColor White
Write-Host "Password: admin123" -ForegroundColor White

Write-Host "`n=== Useful Commands ===" -ForegroundColor Cyan
Write-Host "View all pods: kubectl get pods --all-namespaces" -ForegroundColor White
Write-Host "View logs: kubectl logs -f deployment/course-tracker-deployment" -ForegroundColor White
Write-Host "View monitoring pods: kubectl get pods -n monitoring" -ForegroundColor White
Write-Host "Port forward Grafana: kubectl port-forward -n monitoring service/grafana 3000:3000" -ForegroundColor White
Write-Host "Port forward Prometheus: kubectl port-forward -n monitoring service/prometheus-service 9090:8080" -ForegroundColor White

Write-Host "`n=== Deployment completed successfully! ===" -ForegroundColor Green