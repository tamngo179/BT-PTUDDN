# Copilot Instructions for `k8s-datalake`

## Project Overview
This repository contains Kubernetes manifests for deploying a MinIO-based object storage solution in a namespace called `datalake`. The deployment includes the following components:

1. **MinIO StatefulSet** (`minio-statefulset.yaml`):
   - Deploys a MinIO cluster with 3 replicas.
   - Uses persistent storage with `ReadWriteOnce` access mode.
   - Configures MinIO credentials via Kubernetes Secrets.
   - Exposes two ports:
     - `9000`: API access.
     - `9001`: Console access.

2. **MinIO Service** (`minio-service.yaml`):
   - Provides a `ClusterIP` service for internal communication.
   - Maps ports `9000` and `9001` to the StatefulSet.

3. **MinIO Secret** (`minio-secret.yaml`):
   - Stores base64-encoded credentials for the MinIO cluster.

## Key Patterns and Conventions

### Namespace
- All resources are deployed in the `datalake` namespace. Ensure the namespace exists before applying manifests:
  ```bash
  kubectl create namespace datalake
  ```

### Secrets Management
- The `minio-secret.yaml` file contains base64-encoded credentials. To update credentials:
  1. Encode the new values using:
     ```bash
     echo -n "<value>" | base64
     ```
  2. Replace the `rootUser` and `rootPassword` fields in `minio-secret.yaml`.

### StatefulSet Configuration
- The StatefulSet uses a headless service (`minio`) for internal DNS resolution.
- Data is stored in `/data` and backed by PersistentVolumeClaims (PVCs).
- The `args` field configures MinIO to recognize all replicas in the cluster.

### Service Configuration
- The `ClusterIP` service exposes MinIO's API and console internally within the cluster.

## Developer Workflows

### Applying Manifests
1. Ensure the `kubectl` context is set to the correct cluster.
2. Apply manifests in the following order:
   ```bash
   kubectl apply -f minio-secret.yaml
   kubectl apply -f minio-service.yaml
   kubectl apply -f minio-statefulset.yaml
   ```

### Verifying Deployment
- Check the status of the StatefulSet:
  ```bash
  kubectl get statefulsets -n datalake
  ```
- Verify pods are running:
  ```bash
  kubectl get pods -n datalake
  ```
- Confirm the service is accessible:
  ```bash
  kubectl get svc -n datalake
  ```

### Debugging
- Inspect pod logs:
  ```bash
  kubectl logs <pod-name> -n datalake
  ```
- Describe resources for troubleshooting:
  ```bash
  kubectl describe <resource-type> <resource-name> -n datalake
  ```

## Notes
- The MinIO image version is `latest`. Consider pinning to a specific version for production stability.
- Ensure sufficient storage is available for PVCs.
- This setup is intended for internal cluster use. For external access, additional configuration (e.g., Ingress) is required.