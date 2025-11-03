# Monitor the deployment status
Write-Host "=== Monitoring Deployment Status ===" -ForegroundColor Green

Write-Host "`n=== Namespace Status ===" -ForegroundColor Cyan
kubectl get namespaces

Write-Host "`n=== Application Pods ===" -ForegroundColor Cyan
kubectl get pods -l app=course-tracker

Write-Host "`n=== Monitoring Pods ===" -ForegroundColor Cyan
kubectl get pods -n monitoring

Write-Host "`n=== Services ===" -ForegroundColor Cyan
Write-Host "Application Services:" -ForegroundColor Yellow
kubectl get services

Write-Host "`nMonitoring Services:" -ForegroundColor Yellow
kubectl get services -n monitoring

Write-Host "`n=== Recent Events ===" -ForegroundColor Cyan
kubectl get events --sort-by=.metadata.creationTimestamp

Write-Host "`n=== Access Information ===" -ForegroundColor Green

# Get node IP for NodePort services
$nodeIP = kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}'

Write-Host "Node IP: $nodeIP" -ForegroundColor White

Write-Host "`nApplication URLs:" -ForegroundColor Cyan
Write-Host "Course Tracker: http://$nodeIP:30080 (if using NodePort)" -ForegroundColor White

Write-Host "`nMonitoring URLs:" -ForegroundColor Cyan
Write-Host "Prometheus: http://$nodeIP:30000" -ForegroundColor White
Write-Host "Grafana: http://$nodeIP:32000" -ForegroundColor White
Write-Host "  Username: admin" -ForegroundColor Gray
Write-Host "  Password: admin123" -ForegroundColor Gray

Write-Host "`n=== Port Forward Commands (alternative access) ===" -ForegroundColor Cyan
Write-Host "kubectl port-forward service/course-tracker-service 8080:80" -ForegroundColor White
Write-Host "kubectl port-forward -n monitoring service/prometheus-service 9090:8080" -ForegroundColor White
Write-Host "kubectl port-forward -n monitoring service/grafana 3000:3000" -ForegroundColor White