# Apply all Kubernetes resources
kubectl apply -f k8s/

# Or apply individually:
# kubectl apply -f k8s/configmap.yaml
# kubectl apply -f k8s/deployment.yaml
# kubectl apply -f k8s/service.yaml
# kubectl apply -f k8s/ingress.yaml

# Check deployment status
kubectl get pods -l app=course-tracker

# Check service
kubectl get service course-tracker-service

# Get external IP (for LoadBalancer)
kubectl get service course-tracker-service --watch

# Check logs
kubectl logs -l app=course-tracker

# Delete all resources
# kubectl delete -f k8s/