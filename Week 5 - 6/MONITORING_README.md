# Course Tracker with Kubernetes Monitoring Stack

This guide explains how to deploy the Spring Boot Course Tracker application on Kubernetes with Prometheus monitoring and Grafana visualization.

## Architecture Overview

```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│   Course Tracker    │    │     Prometheus      │    │      Grafana        │
│   (Spring Boot)     │───▶│   (Metrics Store)   │───▶│  (Visualization)    │
│   Port: 8080        │    │   Port: 9090        │    │   Port: 3000        │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
           │                          │                          │
           │                          │                          │
         NodePort                   NodePort                   NodePort
        30080/8080                   30000                      32000
```

## Prerequisites

- Kubernetes cluster (minikube, Docker Desktop, or cloud provider)
- kubectl configured and connected to your cluster
- Docker (for building images)
- PowerShell (for running deployment scripts)

## Quick Start

### 1. Deploy Everything

Run the complete deployment script:

```powershell
cd k8s
.\deploy-all.ps1
```

This will deploy:
- Course Tracker application
- Prometheus monitoring server
- Grafana dashboard
- All necessary configurations and permissions

### 2. Access the Applications

After deployment, access the applications using these URLs (replace `<node-ip>` with your actual node IP):

- **Course Tracker**: http://`<node-ip>`:30080 or http://localhost:8080 (if port-forwarded)
- **Prometheus**: http://`<node-ip>`:30000 or http://localhost:9090 (if port-forwarded)
- **Grafana**: http://`<node-ip>`:32000 or http://localhost:3000 (if port-forwarded)
  - Username: `admin`
  - Password: `admin123`

### 3. Check Status

Monitor the deployment status:

```powershell
.\status.ps1
```

## Alternative Deployment Options

### Deploy Only the Application

If you already have monitoring infrastructure:

```powershell
.\deploy-app-only.ps1
```

### Access via Port Forwarding

If NodePort access doesn't work, use port forwarding:

```bash
# Course Tracker
kubectl port-forward service/course-tracker-service 8080:80

# Prometheus
kubectl port-forward -n monitoring service/prometheus-service 9090:8080

# Grafana
kubectl port-forward -n monitoring service/grafana 3000:3000
```

## Monitoring Features

### Spring Boot Actuator Endpoints

The application exposes these monitoring endpoints:

- `/actuator/health` - Application health status
- `/actuator/metrics` - Application metrics
- `/actuator/prometheus` - Prometheus-formatted metrics
- `/actuator/info` - Application information

### Prometheus Metrics

Prometheus collects these metrics from the application:

- **HTTP Metrics**: Request rates, response times, status codes
- **JVM Metrics**: Memory usage, garbage collection, threads
- **System Metrics**: CPU usage, disk I/O
- **Database Metrics**: Connection pool status, query performance
- **Custom Metrics**: Application-specific business metrics

### Grafana Dashboards

The included dashboard shows:

- HTTP request rate and response times
- JVM memory usage and garbage collection
- System CPU usage
- Database connection pool status
- Course-specific operation metrics

## Customization

### Modifying Prometheus Configuration

Edit `k8s/monitoring/prometheus-config.yaml` to:
- Add new scrape targets
- Modify scrape intervals
- Add alerting rules

### Customizing Grafana Dashboards

1. Access Grafana UI
2. Create or import new dashboards
3. Export the dashboard JSON
4. Update `k8s/monitoring/grafana-dashboard-config.yaml`

### Adding Custom Metrics

In your Spring Boot application, add custom metrics:

```java
@RestController
public class CourseController {
    
    private final Counter courseCreationCounter;
    private final Timer courseRetrievalTimer;
    
    public CourseController(MeterRegistry meterRegistry) {
        this.courseCreationCounter = Counter.builder("courses_created_total")
            .description("Total number of courses created")
            .register(meterRegistry);
        
        this.courseRetrievalTimer = Timer.builder("course_retrieval_duration")
            .description("Course retrieval duration")
            .register(meterRegistry);
    }
    
    @PostMapping("/courses")
    public Course createCourse(@RequestBody Course course) {
        courseCreationCounter.increment();
        // ... rest of the method
    }
}
```

## Troubleshooting

### Common Issues

1. **Pods not starting**: Check resource limits and node capacity
   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   ```

2. **Prometheus not scraping**: Verify pod annotations and network policies
   ```bash
   kubectl logs deployment/prometheus -n monitoring
   ```

3. **Grafana can't connect to Prometheus**: Check service names and ports
   ```bash
   kubectl get services -n monitoring
   ```

### Debug Commands

```bash
# Check all resources
kubectl get all --all-namespaces

# View logs
kubectl logs -f deployment/course-tracker-deployment
kubectl logs -f deployment/prometheus -n monitoring
kubectl logs -f deployment/grafana -n monitoring

# Describe problematic resources
kubectl describe deployment course-tracker-deployment
kubectl describe service prometheus-service -n monitoring

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Cleanup

To remove all deployed resources:

```powershell
.\cleanup.ps1
```

This removes:
- All application deployments and services
- Monitoring stack (Prometheus and Grafana)
- ConfigMaps and secrets
- Monitoring namespace

## Security Considerations

### Production Recommendations

1. **Change default passwords**: Update Grafana admin password
2. **Use secrets**: Store sensitive data in Kubernetes secrets
3. **Enable RBAC**: Restrict service account permissions
4. **Network policies**: Limit pod-to-pod communication
5. **Resource limits**: Set appropriate CPU and memory limits
6. **Image security**: Use specific image tags, not `latest`

### Example Secret for Grafana

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: grafana-credentials
  namespace: monitoring
type: Opaque
data:
  admin-user: YWRtaW4=  # base64 encoded "admin"
  admin-password: <base64-encoded-secure-password>
```

## Performance Tuning

### Prometheus Configuration

- Adjust `scrape_interval` based on your needs (default: 15s)
- Set `retention.time` for data retention (default: 200h)
- Configure `storage.tsdb.retention.size` for disk usage limits

### Resource Allocation

Monitor and adjust resource requests/limits:

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi" 
    cpu: "500m"
```

## Next Steps

1. **Set up alerting**: Configure Prometheus AlertManager
2. **Add more dashboards**: Create dashboards for business metrics
3. **Implement logging**: Add ELK stack or similar for log aggregation
4. **CI/CD integration**: Automate deployment with GitOps
5. **Backup strategy**: Implement backup for Prometheus data and Grafana configs

## References

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Spring Boot Actuator](https://spring.io/guides/gs/actuator-service/)
- [Micrometer Documentation](https://micrometer.io/docs/)